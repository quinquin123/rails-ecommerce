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
                           .where(products: { seller_id: current_user.id }, status: 'paid')
                           .sum(:total_amount) || 0
    
    @sales_count = Order.joins(order_items: :product)
                        .where(products: { seller_id: current_user.id }, status: 'paid')
                        .count

    @total_orders = Order.joins(order_items: :product)
                         .where(products: { seller_id: current_user.id })
                         .distinct.count

    @pending_orders = Order.joins(order_items: :product)
                           .where(products: { seller_id: current_user.id }, status: 'pending')
                           .distinct.count

    @average_order_value = @sales_count > 0 ? (@total_earnings / @sales_count) : 0

    # Time-based analytics
    @monthly_earnings = monthly_earnings_data
    @weekly_sales = weekly_sales_data
    
    # Product analytics
    @top_products_by_revenue = top_products_by_revenue
    @top_products_by_sales = top_products_by_sales
    @top_products_by_reviews = Product.where(seller_id: current_user.id)
                                  .where('reviews_count > 0')
                                  .order(reviews_count: :desc)
                                  .limit(5)
    
    # Customer analytics
    @repeat_customers_count = repeat_customers_count
    @customer_demographics = customer_demographics_data
    
    # Performance metrics
    @conversion_rate = calculate_conversion_rate
    @return_rate = calculate_return_rate
    @average_rating = @products.average(:average_rating) || 0
    
    # Inventory metrics - simplified without stock fields
    @total_products = @products.count
    @active_products = @products.where(status: 'active').count
    @moderated_products = @products.where(status: 'moderated').count
    @deleted_products = @products.where(status: 'deleted').count
  end

  def admin
    @orders = policy_scope(Order)
    authorize Order, :index?
    @total_revenue = Order.where(status: 'paid').sum(:total_amount) || 0
    @active_users = User.where(status: 'active').count
    @pending_sellers = User.where(role: 'seller', status: 'pending_approval').count
    @blocked_user = User.where(status: 'blocked').count
    @active_products = Product.where(status: 'active').count
    @moderated_products = Product.where(status: 'moderated').count
    @deleted_products = Product.where(status: 'deleted').count
  end

  private

  def monthly_earnings_data
    Order.joins(order_items: :product)
         .where(products: { seller_id: current_user.id }, status: 'paid')
         .where('orders.created_at >= ?', 12.months.ago)
         .group("DATE_TRUNC('month', orders.created_at)")
         .sum(:total_amount)
         .transform_keys { |key| key.strftime('%B %Y') }
  end

  def weekly_sales_data
    Order.joins(order_items: :product)
         .where(products: { seller_id: current_user.id }, status: 'paid')
         .where('orders.created_at >= ?', 8.weeks.ago)
         .group("DATE_TRUNC('week', orders.created_at)")
         .count
         .transform_keys { |key| "Week of #{key.strftime('%m/%d')}" }
  end

  def top_products_by_revenue
    OrderItem.joins(:product, :order)
             .where(products: { seller_id: current_user.id }, orders: { status: 'paid' })
             .group(:product_id)
             .sum(:price_at_purchase)
             .sort_by { |_, revenue| -revenue }
             .first(5)
             .map { |product_id, revenue| [Product.find(product_id), revenue] }
  end

  def top_products_by_sales
    # Since no quantity field, count number of order_items (each = 1 product sold)
    OrderItem.joins(:product, :order)
             .where(products: { seller_id: current_user.id }, orders: { status: 'paid' })
             .group(:product_id)
             .count
             .sort_by { |_, count| -count }
             .first(5)
             .map { |product_id, count| [Product.find(product_id), count] }
  end

  def repeat_customers_count
    Order.joins(order_items: :product)
         .where(products: { seller_id: current_user.id }, status: 'paid')
         .group(:buyer_id)
         .having('COUNT(*) > 1')
         .count
         .size
  end

  def customer_demographics_data
    # Order has buyer_id that references users
    orders = Order.joins(order_items: :product)
                  .where(products: { seller_id: current_user.id }, status: 'paid')
    
    location_data = if User.column_names.include?('city')
                      orders.joins(:buyer)
                           .group('users.city')
                           .count
                    else
                      {}
                    end
    
    age_data = if User.column_names.include?('birth_date')
                 orders.joins(:buyer)
                      .where.not(users: { birth_date: nil })
                      .group(
                        "CASE 
                         WHEN EXTRACT(YEAR FROM AGE(users.birth_date)) < 25 THEN '18-24'
                         WHEN EXTRACT(YEAR FROM AGE(users.birth_date)) < 35 THEN '25-34'
                         WHEN EXTRACT(YEAR FROM AGE(users.birth_date)) < 45 THEN '35-44'
                         WHEN EXTRACT(YEAR FROM AGE(users.birth_date)) < 55 THEN '45-54'
                         ELSE '55+'
                         END"
                      ).count
               else
                 {}
               end
    
    {
      by_location: location_data,
      by_age_group: age_data
    }
  end

  def calculate_conversion_rate
    # This would need product view tracking
    # For now, return a placeholder
    0.0
  end

  def calculate_return_rate
    # Count order_items instead of quantities (since no quantity field)
    total_items = OrderItem.joins(:product, :order)
                           .where(products: { seller_id: current_user.id }, orders: { status: 'paid' })
                           .count
    
    returned_items = OrderItem.joins(:product, :order)
                              .where(products: { seller_id: current_user.id }, orders: { status: 'returned' })
                              .count
    
    total_items > 0 ? (returned_items.to_f / total_items * 100).round(2) : 0
  end
end