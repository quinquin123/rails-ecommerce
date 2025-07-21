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
  
  respond_to do |format|
    format.html { redirect_to cart_path, notice: 'Item added to cart.' }
    format.js   # Điều này sẽ tìm file add_item.js.erb
  end
rescue ActiveRecord::RecordNotFound
  respond_to do |format|
    format.html { redirect_to products_path, alert: 'Product not found.' }
    format.js { render js: "alert('Product not found');" }
  end
end

  def remove_item
  authorize @cart
  @cart_item = @cart.cart_items.find(params[:id])
  @cart_item.destroy
  
  respond_to do |format|
    format.html { redirect_to cart_path, notice: 'Item removed from cart.' }
    format.json { render json: { 
      status: 'success', 
      item_id: @cart_item.id,
      new_total: number_to_currency(@cart.reload.total_price),
      cart_empty: @cart.cart_items.empty?
    } }
  end
end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
  
end
