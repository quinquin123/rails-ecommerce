class ReportsController < ApplicationController
  before_action :authenticate_user!

  def buyer
    @orders = policy_scope(Order)
    authorize Order, :index?
    @total_spent = @orders.sum(:total_amount) || 0
    @average_spent = @orders.average(:total_amount) || 0
    @purchases_count = @orders.count
  end

  def seller
    @products = policy_scope(Product)
    authorize Product, :index?
    @total_earnings = Order.joins(order_items: :product)
                          .where(products: { seller_id: current_user.id }, status: 'success')
                          .sum(:total_amount) || 0
    @sales_count = Order.joins(order_items: :product)
                       .where(products: { seller_id: current_user.id }, status: 'success')
                       .count
    @top_products = @products.order(reviews_count: :desc).limit(5)
  end

  def admin
    @orders = policy_scope(Order)
    authorize Order, :index?
    @total_revenue = Order.where(status: 'success').sum(:total_amount) || 0
    @active_users = User.where(status: 'active').count
    @pending_sellers = User.where(role: 'seller', status: 'pending_approval').count
  end
end