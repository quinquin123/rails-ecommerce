class Api::V1::OrdersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update, :retry_payment]
  skip_before_action :verify_authenticity_token

  def index
    @orders = policy_scope(Order).includes(:order_items, :products, :payments)

    if params[:status].present? && valid_status?(params[:status])
      @orders = @orders.where(aasm_state: params[:status])
    end

    @orders = @orders.order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page] || 20)

    render json: {
      orders: ActiveModelSerializers::SerializableResource.new(
        @orders,
        each_serializer: OrderSerializer
      ).as_json,
      meta: pagination_meta(@orders)
    }
  end

  def show
    authorize @order
    render json: @order, serializer: OrderSerializer
  end

  def create
    unless current_user.buyer?
      return render json: { error: 'Only buyers can place orders' }, status: :forbidden
    end

    cart = current_user.cart || current_user.create_cart

    if cart.cart_items.empty?
      return render json: { error: 'Cart is empty' }, status: :unprocessable_entity
    end

    authorize cart

    @order = current_user.orders.build(
      total_amount: cart.total_price,
      payment_method: order_params[:payment_method]
    )

    authorize @order

    ActiveRecord::Base.transaction do
      if @order.save
        create_order_items_from_cart(cart)
        OrderProcessingJob.perform_later(@order.id)
        cart.cart_items.destroy_all

        render json: {
          message: 'Order created successfully! Payment is being processed.',
          order: OrderSerializer.new(@order).as_json
        }, status: :created
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Order creation failed: #{e.message}" }, status: :unprocessable_entity
    rescue AASM::InvalidTransition => e
      render json: { error: "Order state error: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def update
    authorize @order

    if @order.update(order_params.except(:payment_method))
      render json: @order, serializer: OrderSerializer
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def retry_payment
    authorize @order, :update?

    unless @order.can_be_retried? && @order.may_retry_payment?
      return render json: { error: 'This order cannot be retried' }, status: :unprocessable_entity
    end

    begin
      @order.retry_payment!
      OrderProcessingJob.perform_later(@order.id)

      render json: {
        message: 'Payment retry initiated',
        order: OrderSerializer.new(@order).as_json
      }
    rescue AASM::InvalidTransition => e
      render json: { error: 'Unable to retry payment at this time' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Order not found' }, status: :not_found
  end

  def order_params
    params.require(:order).permit(:payment_method)
  end

  def create_order_items_from_cart(cart)
    cart.cart_items.each do |cart_item|
      @order.order_items.create!(
        product: cart_item.product,
        price_at_purchase: cart_item.product.price
      )
    end
  end

  def valid_status?(status)
    %w[pending paid failed].include?(status)
  end
end
