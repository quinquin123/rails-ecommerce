require 'aasm'

class Order < ApplicationRecord
  include AASM
  
  belongs_to :buyer, class_name: 'User'
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :products, through: :order_items
  
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true

  aasm column: :aasm_state do
    state :pending, initial: true
    state :processing
    state :success
    state :failed
    state :refunded
    
    event :start_processing do
      transitions from: :pending, to: :processing, after: :create_processing_payment
    end
    
    event :mark_successful do
      transitions from: [:pending, :processing], to: :success, after: :handle_successful_payment
    end
    
    event :mark_failed do
      transitions from: [:pending, :processing], to: :failed, after: :handle_failed_payment
    end
    
    event :refund do
      transitions from: [:success], to: :refunded, after: :process_refund
    end
    
    event :retry_payment do
      transitions from: :failed, to: :pending
    end
  end
  
  scope :successful, -> { where(aasm_state: 'success') }
  scope :failed_orders, -> { where(aasm_state: 'failed') }
  scope :pending_orders, -> { where(aasm_state: 'pending') }
  scope :processing_orders, -> { where(aasm_state: 'processing') }
  
  def status
    aasm_state
  end
  
  def mark_as_successful!
    mark_successful! if may_mark_successful?
  end
  
  def can_be_retried?
    failed?
  end
  
  def can_be_refunded?
    success?
  end
  
  def downloadable?
    success?
  end
  
  private
  
  def create_processing_payment
    payments.create!(
      status: 'processing',
      amount: total_amount
    )
    Rails.logger.info "Order ##{id} moved to processing state"
  end
  
  def handle_successful_payment
    payments.create!(
      status: 'success',
      amount: total_amount
    )
    
    order_items.each do |item|
      item.update!(download_expires_at: 1.year.from_now)
    end
    
    Rails.logger.info "Order ##{id} completed successfully"
  end
  
  def handle_failed_payment
    payments.create!(
      status: 'failed',
      amount: total_amount
    )
    
    Rails.logger.info "Order ##{id} payment failed"
  end
  
  def process_refund
    payments.create!(
      status: 'refunded',
      amount: -total_amount
    )
    
    order_items.update_all(download_expires_at: nil)
    
    Rails.logger.info "Order ##{id} refunded"
  end
end