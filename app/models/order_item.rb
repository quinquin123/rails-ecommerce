class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Kiểm tra download còn hiệu lực
  def downloadable?
    download_expires_at.nil? || download_expires_at > Time.current
  end
end
