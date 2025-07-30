class Payment < ApplicationRecord
  belongs_to :order
  
  validates :status, presence: true, inclusion: { in: %w[processing success failed refunded] }
  validates :amount, presence: true
  
  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failed') }
  scope :processing, -> { where(status: 'processing') }
  
  def successful?
    status == 'success'
  end
  
  def failed?
    status == 'failed'
  end
  
  def processing?
    status == 'processing'
  end
  
  def refunded?
    status == 'refunded'
  end
end