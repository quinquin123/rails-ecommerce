class Review < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :product
  belongs_to :order
  validates :rating, inclusion: { in: 1..5 }
  validates :buyer_id, uniqueness: { scope: :product_id }

  #CallBacks
  after_save :update_product_rating
  after_destroy :update_product_rating
  
  private
  def update_product_rating
    product.update(
      average_rating: product.reviews.average(:rating).to_f.round(1),
      reviews_count: product.reviews.count
    )
  end
end