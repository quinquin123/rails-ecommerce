class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, only: [:show]
  def index
    @orders = policy_scope(Order).order(created_at: :desc)
    authorize Order
  end
  def show
    authorize @order
  end
  def new
    @cart = current_user.cart
    redirect_to cart_path, alert: "Your cart is empty" and return if @cart.cart_items.empty?
    @order = current_user.orders.build(
      total_amount: @cart.total_price,
      status: 'pending'
    )
    authorize @order
  end
  def create
    @cart = current_user.cart
    authorize @cart

    @order = current_user.orders.build(
      total_amount: @cart.total_price,
      status: 'pending',
      payment_method: order_params[:payment_method]
    )
    authorize @order

    ActiveRecord::Base.transaction do
      if @order.save
        @cart.cart_items.each do |item|
          @order.order_items.create!(
            product_id: item.product_id,
            price_at_purchase: item.product.price,
          )
        end
        payment = @order.payments.create!(status: 'success', amount: @order.total_amount)
        @order.update!(status: 'success')
        @cart.cart_items.destroy_all 
        redirect_to orders_path, notice: 'Order placed successfully'
      else
        render :new
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to cart_path, alert: "Order creation failed: #{e.message}"
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
end