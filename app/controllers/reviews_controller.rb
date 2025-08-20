class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  def index
    @reviews = Review.includes(:buyer, :product, :order)
                    .order(created_at: :desc)
                    .page(params[:page]).per(10)
    authorize @reviews
  end

  def show
    authorize @review
  end

  def new
    @product = Product.find(params[:product_id])
    @review = Review.new(product: @product)
    authorize @review
    
    unless current_user.orders.joins(:order_items)
                      .where(order_items: { product: @product })
                      .where(aasm_state: 'paid').exists?
      redirect_to @product, alert: 'You need to purchase this product before reviewing.'
      return
    end
    
    if Review.exists?(buyer: current_user, product: @product)
      redirect_to @product, alert: 'You have already reviewed this product.'
      return
    end
  end

  def create
    @product = Product.find(review_params[:product_id])
    @order = Order.find(review_params[:order_id]) if review_params[:order_id].present?
    
    @review = Review.new(review_params.merge(buyer_id: current_user.id))
    authorize @review
    
    unless can_user_review?(@review.product, @order)
      if @order
        redirect_to @order, alert: 'You cannot review this product.'
      else
        redirect_to @review.product, alert: 'You cannot review this product.'
      end
      return
    end
    
    if @review.save
      if @order
        redirect_to @order, notice: 'Review created successfully!'
      else
        redirect_to @review.product, notice: 'Review created successfully!'
      end
    else
      if @order
        redirect_to @order, alert: "Failed to create review: #{@review.errors.full_messages.join(', ')}"
      else
        redirect_to @review.product, alert: "Failed to create review: #{@review.errors.full_messages.join(', ')}"
      end
    end
  end

  def edit
    authorize @review
  end

  def update
    authorize @review
    
    if @review.update(review_params.except(:product_id, :order_id))
      if params[:review][:order_id].present?
        order = Order.find(params[:review][:order_id])
        redirect_to order, notice: 'Review updated successfully!'
      else
        redirect_to @review.product, notice: 'Review updated successfully!'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    product = @review.product
    order_id = params[:order_id]
    authorize @review
    
    @review.destroy
    
    if order_id.present?
      order = Order.find(order_id)
      redirect_to order, notice: 'Review deleted successfully.'
    else
      redirect_to product, notice: 'Review deleted successfully.'
    end
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:product_id, :order_id, :rating, :comment)
  end
  
  def can_user_review?(product, order = nil)
    return false unless current_user.buyer?
    
    if order
      return false unless order.buyer_id == current_user.id
      return false unless order.paid?
      return false unless order.order_items.joins(:product).where(products: { id: product.id }).exists?
    else
      return false unless current_user.orders.joins(:order_items)
                                    .where(order_items: { product: product })
                                    .where(aasm_state: 'paid').exists?
    end
    
    return false if Review.exists?(buyer: current_user, product: product)
    
    true
  end
end