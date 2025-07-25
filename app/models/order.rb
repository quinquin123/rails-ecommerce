class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  has_many :order_items, dependent: :destroy
  has_many :payments
  has_many :products, through: :order_items
  enum status: { pending: 'pending', success: "success", failed: "failed", refunded: "refunded" }

  def mark_as_successful!
    update!(status: 'success')
    order_items.each do |item|
      item.update!(download_expires_at: 1.year.from_now) # Thời hạn download
    end
  end

  scope :successful, -> { where(status: 'success') }
end
