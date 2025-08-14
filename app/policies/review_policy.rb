# app/policies/review_policy.rb
class ReviewPolicy < ApplicationPolicy
  def index?
    true 
  end

  def show?
    true
  end

  def new?
    user&.buyer? && can_review_product?
  end

  def create?
    user&.buyer? && can_review_product?
  end

  def edit?
    user&.buyer? && record.buyer == user
  end

  def update?
    user&.buyer? && record.buyer == user
  end

  def destroy?
    user&.admin? || (user&.buyer? && record.buyer == user)
  end

  private

  def can_review_product?
    return false unless record&.product
    
    user.orders.joins(:order_items)
        .where(order_items: { product: record.product })
        .where(status: 'paid').exists?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end