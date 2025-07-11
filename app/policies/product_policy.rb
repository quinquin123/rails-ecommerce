class ProductPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      if user.admin?
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
    user.seller? || user.admin?
  end

  def update?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  def destroy?
    user.admin? || (user.seller? && record.seller_id == user.id)
  end

  #Duyet sp
  def moderate?
    user.admin?
  end

end
