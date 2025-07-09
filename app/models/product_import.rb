class ProductImport < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  enum status: { pending: 'pending', processed: 'processed', failed: 'failed' }
end
