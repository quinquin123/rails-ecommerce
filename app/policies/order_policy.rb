class OrderPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.seller?
        scope.joins(order_items: :product).where(products: { seller_id: user.id })
      else
        scope.where(buyer_id: user.id)
      end
    end
  end
  
  def index?
    true
  end

  def show?
    user.admin? || record.buyer_id == user.id || record.products.where(seller_id: user.id).exists?
  end

  def create?
    user.buyer?
  end

  def update?
    user.admin? 
  end
end