class PaymentRetryService
  def self.call(user)
    user.orders.pending.each do |order|
      Rails.logger.info "Retrying payment for Order ##{order.id}"

      success = [true, false].sample

      if success
        order.update!(aasm_state: 'paid', status: 'paid')
        Rails.logger.info "Order ##{order.id} marked as paid"
      else
        order.update!(aasm_state: 'failed', status: 'failed')
        Rails.logger.warn "Order ##{order.id} marked as failed"
      end
    end
  end
end
