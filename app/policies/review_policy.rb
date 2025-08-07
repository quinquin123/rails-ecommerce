# app/policies/review_policy.rb
class ReviewPolicy < ApplicationPolicy
  def index?
    true # Anyone can see reviews
  end

  def show?
    true # Anyone can see individual reviews
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
    user&.buyer? && (record.buyer == user || user.admin?)
  end

  private

  def can_review_product?
    return false unless record&.product
    
    # User must have purchased the product in a paid order
    user.orders.joins(:order_items)
        .where(order_items: { product: record.product })
        .where(aasm_state: 'paid').exists?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end