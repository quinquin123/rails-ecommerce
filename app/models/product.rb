class Product < ApplicationRecord
  after_save :store_urls
  include PgSearch::Model

  pg_search_scope :search_by_title_and_description,
    against: [:title, :description],
    using: {
      tsearch: { prefix: true }
    }

  attr_accessor :remove_preview_image, :remove_downloadable_asset, :remove_video

  belongs_to :seller, class_name: 'User'
  belongs_to :category
  has_many :cart_items
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy
  #has_many :carts, through: :cart_items

  has_one_attached :video
  has_one_attached :preview_image
  has_one_attached :downloadable_asset
  has_one_attached :video_thumbnail


  validate :validate_media_presence
  validate :validate_video_format, if: -> { video.attached? }
  validate :validate_image_format, if: -> { preview_image.attached? }

  after_create_commit :generate_thumbnail_later
  after_update_commit :generate_thumbnail_later, if: -> { attachment_changes.key?(:video) }
  
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
    return if Rails.env.test?
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

    return true if user == seller

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

  def video?
    video.attached?
  end
  def image?
    preview_image.attached? && !video?
  end
  def media_type
    video? ? :video : :image
  end
  def generate_thumbnail_later
    return unless video.attached?
    VideoThumbnailJob.perform_later(id)
  end

  private
  def extract_thumbnail
    VideoThumbnailJob.perform_later(self)
  end
  def validate_media_presence
    return if video.attached? || preview_image.attached?
    errors.add(:base, "You must attach either a video or an image")
  end
  def validate_video_format
    return if video.content_type.in?(%w[video/mp4 video/quicktime video/x-msvideo])
    errors.add(:video, "must be a MP4, MOV or AVI file")
  end
  def validate_image_format
    return if preview_image.content_type.in?(%w[image/jpeg image/png image/gif])
    errors.add(:preview_image, "must be a JPEG, PNG or GIF file")
  end
end