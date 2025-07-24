class Product < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_title_and_description,
    against: [:title, :description],
    using: {
      tsearch: { prefix: true }
    }

  attr_accessor :remove_preview_image, :remove_downloadable_asset

  belongs_to :seller, class_name: 'User'
  belongs_to :category
  has_many :cart_items
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy
  #has_many :carts, through: :cart_items

  has_one_attached :preview_image
  has_one_attached :downloadable_asset

  enum status: { active: 'active', moderated: 'moderated', deleted: 'deleted' }
  validates :title, :price, :status, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def thumbnail 
    preview_image.variant(resize_to_limit: [300, 300]).processed
  end

  def preview 
    preview_image.variant(resize_to_limit: [800, 800]).processed
  end
end
