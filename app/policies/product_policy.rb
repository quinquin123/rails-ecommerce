class ProductPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.where(status: 'active')
      elsif user.admin?
        scope.all
      elsif user.seller?
        scope.where(seller_id: user.id)
      else
        scope.where(status: 'active')
      end
    end
  end

  def index?
    true
  end

  def show?
    return false if user&.seller? && user.pending_approval?
    record.status == 'active' || user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def create?
    return false unless user.present?
    raise Errors::PendingApprovalError if user.seller? && user.pending_approval?
    user.seller? || user.admin?
  end

  def update?
    return false unless user.present?
    raise Errors::PendingApprovalError if user.seller? && user.pending_approval?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def destroy?
    return false unless user.present?
    raise Errors::PendingApprovalError if user.seller? && user.pending_approval?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def approve?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def restore?
    user&.admin?
  end

  def download?
    return true if record.price.zero?
    return false unless user
    user.orders.paid_orders.joins(:order_items)
        .where(order_items: { product_id: record.id }).exists?
  end

end
