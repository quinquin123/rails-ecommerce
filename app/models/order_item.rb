class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Kiểm tra download còn hiệu lực
  def downloadable?
    download_expires_at.nil? || download_expires_at > Time.current
  end
  #download_expires_at.nil?: Không có hạn tải
  #download_expires_at > Time.current: Hạn tải còn sau thời điểm hiện tại vẫn tải được.
  # item = OrderItem.new(download_expires_at: nil)
  # item.downloadable?  # => true

  # item = OrderItem.new(download_expires_at: 2.days.from_now)
  # item.downloadable?  # => true

  # item = OrderItem.new(download_expires_at: 1.day.ago)
  # item.downloadable?  # => false

end
