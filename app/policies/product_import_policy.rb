class ProductImportPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(seller_id: user.id)
      end
    end
  end

  def index?
    user.seller? || user.admin?
  end

  def show?
    user.admin? || record.seller_id == user.id
  end

  def create?
    user.seller? || user.admin?
  end
end
