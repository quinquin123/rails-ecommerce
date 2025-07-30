class OrderProcessingJob < ApplicationJob
  queue_as :default
  
  def perform(order_id)
    order = Order.find(order_id)
    
    Rails.logger.info "Processing payment for Order ##{order.id}"
    
    payment_result = process_payment(order)
    
    if payment_result[:success]
      if order.may_mark_successful?
        order.mark_successful!
        Rails.logger.info "Order ##{order.id} payment successful"
      end
    else
      if order.may_mark_failed?
        order.mark_failed!
        
        latest_payment = order.payments.order(:created_at).last
        latest_payment.update!(
          failure_reason: payment_result[:error_message],
          processed_at: Time.current
        ) if latest_payment
        
        Rails.logger.error "Order ##{order.id} payment failed: #{payment_result[:error_message]}"
      end
    end
    
  rescue StandardError => e
    Rails.logger.error "Order processing job failed: #{e.message}"
    
    if order.may_mark_failed?
      order.mark_failed!
      
      latest_payment = order.payments.order(:created_at).last
      latest_payment.update!(
        failure_reason: "Processing error: #{e.message}",
        processed_at: Time.current
      ) if latest_payment
    end
    
    raise e
  end
  
  private
  
  def process_payment(order)
    
    sleep(2) 
    
    if rand > 0.15
      {
        success: true,
        transaction_id: "txn_#{SecureRandom.hex(8)}",
        processed_at: Time.current
      }
    else
      error_messages = [
        "Insufficient funds",
        "Card declined",
        "Network timeout",
        "Invalid payment method"
      ]
      
      {
        success: false,
        error_message: error_messages.sample,
        processed_at: Time.current
      }
    end
  end
end