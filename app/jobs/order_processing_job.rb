class OrderProcessingJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    Rails.logger.info "Starting payment processing for Order ##{order.id}"

    payment_result = process_payment(order)

    if payment_result[:success]
      mark_paid(order)
    else
      mark_failed(order, payment_result[:error_message])
    end

  rescue StandardError => e
    Rails.logger.error "Unexpected error: #{e.message}"
    mark_failed(order, "Unhandled error: #{e.message}")
    raise e
  end

  private

  def process_payment(order)
    sleep(2) # Giả lập việc xử lý
    success = rand > 0.15

    if success
      {
        success: true,
        transaction_id: "txn_#{SecureRandom.hex(8)}",
        processed_at: Time.current
      }
    else
      {
        success: false,
        error_message: [
          "Insufficient funds", "Card declined",
          "Network timeout", "Invalid payment method"
        ].sample,
        processed_at: Time.current
      }
    end
  end

  def mark_paid(order)
    if order.may_mark_paid?
      order.mark_paid!
      Rails.logger.info "Order ##{order.id} successfully marked as paid"
    else
      Rails.logger.warn "Cannot mark Order ##{order.id} as paid. Current state: #{order.aasm_state}"
    end
  end

  def mark_failed(order, reason)
    return unless order.may_mark_failed?

    order.mark_failed!
    latest_payment = order.payments.order(:created_at).last

    if latest_payment
      latest_payment.update!(
        failure_reason: reason,
        processed_at: Time.current
      )
    end

    Rails.logger.warn "Order ##{order.id} failed: #{reason}"
  end
end
