class Api::V1::CartsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_cart
  skip_before_action :verify_authenticity_token

  # GET /api/v1/cart
  def show
    authorize @cart
    render json: @cart, include: :cart_items, status: :ok
  end

  # POST /api/v1/cart/add_item
  def add_item
    authorize @cart

    product = Product.find_by(id: params[:product_id])
    unless product
      return render json: { error: 'Product not found' }, status: :not_found
    end

    # kiểm tra trùng lặp trong giỏ hàng
    if @cart.cart_items.exists?(product_id: product.id)
      return render json: { error: 'Product already in cart' }, status: :unprocessable_entity
    end

    cart_item = @cart.cart_items.create(product: product)

    if cart_item.persisted?
      render json: { message: 'Item added to cart', cart_item: cart_item }, status: :created
    else
      render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/cart/remove_item
  def remove_item
    authorize @cart

    cart_item = @cart.cart_items.find_by(id: params[:id])
    unless cart_item
      return render json: { error: 'Item not found' }, status: :not_found
    end

    cart_item.destroy
    render json: { message: 'Item removed from cart' }, status: :ok
  end

  private

  def set_cart
    unless current_user.buyer?
      return render json: { error: "Only buyers can have carts" }, status: :forbidden
    end
    @cart = current_user.cart || current_user.create_cart
  end
end
