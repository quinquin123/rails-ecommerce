class OrderProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(order_id)
    order = Order.find(order_id)
    
    # Giả lập xử lý thanh toán
    payment_success = process_payment(order)

    if payment_success
      order.payments.create!(
        status: 'success',
        amount: order.total_amount
      )
      order.complete!
    else
      order.payments.create!(
        status: 'failed',
        amount: order.total_amount
      )
      order.fail!
    end
  end

  private

  def process_payment(order)
    # Thực tế sẽ gọi API thanh toán ở đây
    # Tạm thời giả lập 80% thành công
    rand(1..100) <= 80
  end
end