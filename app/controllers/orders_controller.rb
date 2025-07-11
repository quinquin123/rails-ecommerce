class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]

  def index
    @orders = policy_scope(Order)
    authorize Order
  end

  def show
    authorize @order
  end

  def create
    @cart = current_user.cart
    authorize @cart
    @order = current_user.orders.build(total_amount: @cart.products.sum(:price))
    authorize @order
    @order.status = 'pending'
    if @order.save
      @cart.cart_items.each do |item|
        @order.order_items.create(
          product_id: item.product_id,
          price_at_purchase: item.product.price,
          download_url: item.product.download_url
        )
      end
      payment = @order.payments.create(status: %w[success failed].sample)
      if payment.status == 'success'
        @order.update(status: 'success')
        @cart.cart_items.destroy_all
        redirect_to @order, notice: 'Order placed successfully.'
      else
        @order.update(status: 'failed')
        redirect_to cart_path, alert: 'Payment failed.'
      end
    else
      redirect_to cart_path, alert: 'Order creation failed.'
    end
  end
  
  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Order not found.'
  end
end
