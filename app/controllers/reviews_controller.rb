class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    @review = Review.new(review_params.merge(buyer_id: current_user.id))
    authorize @review
    if @review.save
      @review.product.update(
        average_rating: @review.product.reviews.average(:rating).to_f.round(1),
        reviews_count: @review.product.reviews.count
      )
      redirect_to @review.product, notice: 'Review created successfully.'
    else
      redirect_to @review.product, alert: 'Failed to create review.'
    end
  end

  private

  def review_params
    params.require(:review).permit(:product_id, :order_id, :rating, :comment)
  end
  
end
