class ProductPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

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
    record.status == 'active' || user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def create?
    user.present? && (user.seller? || user.admin?)
  end

  def update?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def destroy?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def moderate?
    user.admin?
  end

  def download?
    return true if record.price.zero?
    return false unless user
    user.orders.successful.joins(:order_items)
        .where(order_items: { product_id: record.id }).exists?
  end

end
