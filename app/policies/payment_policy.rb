class PaymentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:order).where(orders: { buyer_id: user.id })
      end
    end
  end

  def index?
    user.admin?
  end

  def show?
    user.admin? || record.order.buyer_id == user.id
  end 
end
