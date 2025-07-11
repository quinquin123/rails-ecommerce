class CartPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(buyer_id: user.id)
    end
  end

  def show?
    record.buyer_id == user.id
  end

  def create?
    user.buyer?
  end

  def update?
    record.buyer_id == user.id
  end

  def destroy?
    record.buyer_id == user.id
  end

  def add_item?
    record.buyer_id == user.id
  end

  def remove_item?
    record.buyer_id == user.id
  end
end
