class OrderItemPolicy < ApplicationPolicy
  def download?
    record.order.success? && record.order.user == user
  end
end