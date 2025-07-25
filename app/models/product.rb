class Product < ApplicationRecord
  after_save :store_urls
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

  def store_urls
    if preview_image.attached?
      update_column(:preview_url, preview_image.url)
    end

    if downloadable_asset.attached?
      update_column(:download_url, downloadable_asset.url)
    end
  end

  def downloadable_by?(user)
    return true if price.zero?
    return false unless user.present?

    user.orders.successful.joins(:order_items).where(order_items: { product_id: id }).exists?
  end

  def download_url
    return nil unless downloadable_asset.attached?
    if price.zero?
      Rails.application.routes.url_helpers.url_for(downloadable_asset)
    else
      Rails.application.routes.url_helpers.rails_blob_url(
        downloadable_asset,
        disposition: :attachment,
        expires_in: 1.hour
      )
    end
  end
end
