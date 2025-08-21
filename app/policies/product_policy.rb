class ProductPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def initialize(user, scope, view_type = :default)
      super(user, scope)
      @view_type = view_type
    end

    def resolve
      case @view_type
      when :my_products
        user.seller? ? scope.where(seller_id: user.id) : scope.none
      when :all_products
        if user.nil?
          scope.where(status: 'active')
        elsif user.admin?
          scope.all
        elsif user.seller?
          scope.where(status: 'active').or(scope.where(seller_id: user.id))
        else
          scope.where(status: 'active')
        end
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

  def delete?
    return false unless user.present?
    raise Errors::PendingApprovalError if user.seller? && user.pending_approval?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def approve?
    user&.admin?
  end

  def refuse?
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
