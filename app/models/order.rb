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
    state :paid
    state :failed

    event :mark_paid do
      transitions from: :pending, to: :paid, after: :handle_paid_payment
    end

    event :mark_failed do
      transitions from: :pending, to: :failed, after: :handle_failed_payment
    end

    event :retry_payment do
      transitions from: :failed, to: :pending
    end
  end

  scope :pending_orders, -> { where(aasm_state: 'pending') }
  scope :paid_orders, -> { where(aasm_state: 'paid') }
  scope :failed_orders, -> { where(aasm_state: 'failed') }

  def status
    aasm_state
  end

  def mark_as_paid!
    mark_paid! if may_mark_paid?
  end

  def can_be_retried?
    failed?
  end

  def downloadable?
    paid?
  end

  private

  def handle_paid_payment
    payments.create!(
      status: 'paid',
      amount: total_amount
    )

    order_items.each do |item|
      item.update!(download_expires_at: 1.year.from_now)
    end
    update!(status: 'paid')

    Rails.logger.info "Order ##{id} marked as paid"
  end

  def handle_failed_payment
    payments.create!(
      status: 'failed',
      amount: total_amount
    )
    update!(status: 'failed')

    Rails.logger.info "Order ##{id} payment failed"
  end
end
