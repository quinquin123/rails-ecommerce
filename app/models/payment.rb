class Payment < ApplicationRecord
  belongs_to :order
  enum status: { success: 'success', failed: 'failed' } 

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
