class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [:show, :add_item, :remove_item]

  def show
    authorize @cart
  end

  def add_item
    authorize @cart
    product = Product.find(params[:product_id])
    @cart.cart_items.create(product: product)
    redirect_to cart_path, notice: 'Item added to cart.'
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found.'
  end

  def remove_item
    authorize @cart
    cart_item = @cart.cart_items.find(params[:id])
    cart_item.destroy
    redirect_to cart_path, notice: 'Item removed from cart.'
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Item not found.'
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
  
end
