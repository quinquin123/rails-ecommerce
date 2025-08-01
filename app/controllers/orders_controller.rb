class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, only: [:show, :retry_payment]
  
  def index
    @orders = policy_scope(Order).includes(:order_items, :products, :payments)
                                 .order(created_at: :desc)
    authorize Order
    
    if params[:status].present? && %w[pending processing success failed refunded].include?(params[:status])
      @orders = @orders.where(aasm_state: params[:status])
    end

    @orders = Order.order(created_at: :desc).page(params[:page]).per(10)
  end
  
  def show
    authorize @order
    @order_items = @order.order_items.includes(:product)
  end
  
  def new
    @cart = current_user.cart
    redirect_to cart_path, alert: "Your cart is empty" and return if @cart.cart_items.empty?
    
    @order = current_user.orders.build(
      total_amount: @cart.total_price
    )
    authorize @order
  end
  
  def create
    @cart = current_user.cart
    authorize @cart

    @order = current_user.orders.build(
      total_amount: @cart.total_price,
      payment_method: order_params[:payment_method]
    )
    authorize @order

    ActiveRecord::Base.transaction do
      if @order.save
        create_order_items_from_cart
        
        @order.start_processing! if @order.may_start_processing?
        
        OrderProcessingJob.perform_later(@order.id)
        
        @cart.cart_items.destroy_all
        
        redirect_to order_path(@order), notice: 'Order created successfully! Payment is being processed.'
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to cart_path, alert: "Order creation failed: #{e.message}"
    rescue AASM::InvalidTransition => e
      redirect_to cart_path, alert: "Order state error: #{e.message}"
    end
  end
  
  def retry_payment
    authorize @order, :update?
    
    if @order.can_be_retried? && @order.may_retry_payment?
      begin
        @order.retry_payment!
        @order.start_processing! if @order.may_start_processing?
        
        OrderProcessingJob.perform_later(@order.id)
        
        redirect_to @order, notice: 'Payment retry initiated. Please wait...'
      rescue AASM::InvalidTransition
        redirect_to @order, alert: 'Unable to retry payment at this time.'
      end
    else
      redirect_to @order, alert: 'This order cannot be retried.'
    end
  end
  
  private
  
  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
  
  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Order not found.'
  end
  
  def order_params
    params.require(:order).permit(:shipping_address, :payment_method)
  end
  
  def create_order_items_from_cart
    @cart.cart_items.each do |cart_item|
      @order.order_items.create!(
        product: cart_item.product,
        price_at_purchase: cart_item.product.price
      )
    end
  end
end