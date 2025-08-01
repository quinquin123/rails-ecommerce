class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  validates :product_id, uniqueness: { scope: :cart_id, message: "is already in cart" }
  
  def total_price
    product.price
  end
end
