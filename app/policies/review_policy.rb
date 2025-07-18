class ReviewPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.seller?
        scope.joins(:product).where(products: { seller_id: user.id })
      else
        scope.where(buyer_id: user.id)
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.buyer? && record.order.buyer_id == user.id
  end

  def update?
    user.admin? || record.buyer_id == user.id
  end

  def destroy?
    user.admin? || record.buyer_id == user.id
  end
end
