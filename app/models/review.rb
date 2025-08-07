# app/models/review.rb
class Review < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :product
  belongs_to :order, optional: true

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :buyer_id, uniqueness: { scope: :product_id, message: "You can only review a product once" }
  
  # Validate that the buyer has actually purchased this product
  validate :buyer_must_have_purchased_product
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :with_comments, -> { where.not(comment: [nil, '']) }
  
  def rating_stars
    '★' * rating + '☆' * (5 - rating)
  end
  
  def rating_percentage
    (rating.to_f / 5 * 100).round
  end

  private

  def buyer_must_have_purchased_product
    return unless buyer && product
    
    # Check if buyer has any paid order containing this product
    unless buyer.orders.joins(:order_items)
                      .where(order_items: { product: product })
                      .where(aasm_state: 'paid').exists?
      errors.add(:base, "You can only review products you have purchased")
    end
  end
end