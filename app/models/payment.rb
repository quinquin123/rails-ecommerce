class Payment < ApplicationRecord
  belongs_to :order
  enum status: { success: 'success', failed: 'failed' } 
end
