class Product < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  belongs_to :category
  has_many :cart_items
  has_many :reviews
  has_many :order_items
  #has_many :carts, through: :cart_items
  enum status: { active: 'active', moderated: 'moderated', deleted: 'deleted' }
  validates :title, :price, :status, presence: true
end
