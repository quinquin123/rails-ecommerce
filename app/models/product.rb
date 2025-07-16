class Product < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_title_and_description,
    against: [:title, :description],
    using: {
      tsearch: { prefix: true }
    }
    
  belongs_to :seller, class_name: 'User'
  belongs_to :category
  has_many :cart_items
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy
  #has_many :carts, through: :cart_items
  enum status: { active: 'active', moderated: 'moderated', deleted: 'deleted' }
  validates :title, :price, :status, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :reviews_count, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: :active) }
end
