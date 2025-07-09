class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  has_many :order_items, dependent: :destroy
  has_many :payments
  has_many :products, through: :order_items
  enum status: { pending: 'pending', success: "success", failed: "failed", refunded: "refunded" }
end
