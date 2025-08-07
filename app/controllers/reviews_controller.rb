# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  # GET /reviews (optional - for listing all reviews)
  def index
    @reviews = Review.includes(:buyer, :product, :order)
                    .order(created_at: :desc)
                    .page(params[:page])
    authorize @reviews
  end

  # GET /reviews/1 (optional - for showing individual review)
  def show
    authorize @review
  end

  # GET /reviews/new (optional - if you want a separate new review page)
  def new
    @product = Product.find(params[:product_id])
    @review = Review.new(product: @product)
    authorize @review
    
    # Check if user has purchased the product
    unless current_user.orders.joins(:order_items)
                      .where(order_items: { product: @product })
                      .where(aasm_state: 'paid').exists?
      redirect_to @product, alert: 'You need to purchase this product before reviewing.'
      return
    end
    
    # Check if user has already reviewed
    if Review.exists?(buyer: current_user, product: @product)
      redirect_to @product, alert: 'You have already reviewed this product.'
      return
    end
  end

  # POST /reviews
  def create
    @product = Product.find(review_params[:product_id])
    @order = Order.find(review_params[:order_id]) if review_params[:order_id].present?
    
    @review = Review.new(review_params.merge(buyer_id: current_user.id))
    authorize @review
    
    # Validate user can review
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

  # GET /reviews/1/edit (optional - for editing reviews)
  def edit
    authorize @review
  end

  # PATCH/PUT /reviews/1 (optional - for updating reviews)
  def update
    authorize @review
    
    if @review.update(review_params.except(:product_id, :order_id))
      # Redirect back to order if we have the order_id, otherwise to product
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

  # DELETE /reviews/1 (optional - for deleting reviews)
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
    # User must be a buyer
    return false unless current_user.buyer?
    
    # If we have a specific order, check that order contains the product and is paid
    if order
      return false unless order.buyer_id == current_user.id
      return false unless order.paid?
      return false unless order.order_items.joins(:product).where(products: { id: product.id }).exists?
    else
      # User must have purchased the product in any paid order
      return false unless current_user.orders.joins(:order_items)
                                    .where(order_items: { product: product })
                                    .where(aasm_state: 'paid').exists?
    end
    
    # User must not have already reviewed this product
    return false if Review.exists?(buyer: current_user, product: product)
    
    true
  end
end