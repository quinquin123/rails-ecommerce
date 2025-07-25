class Cart < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  has_many :cart_items, dependent: :destroy 
  has_many :products, through: :cart_items

  def total_price
    cart_items.joins(:product).sum('products.price')
  end
end
