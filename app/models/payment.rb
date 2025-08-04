class Payment < ApplicationRecord
  belongs_to :order
  
  validates :status, presence: true, inclusion: { in: %w[pending paid failed] }
  validates :amount, presence: true
  
  scope :successful, -> { where(status: 'paid') }
  scope :failed, -> { where(status: 'failed') }
  scope :processing, -> { where(status: 'pending') }
  
  def successful?
    status == 'paid'
  end
  
  def failed?
    status == 'failed'
  end
  
  def processing?
    status == 'pending'
  end
end