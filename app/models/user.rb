class User < ApplicationRecord
  has_secure_password

  has_many :orders
  has_many :items

  validates_presence_of :name, :address, :city, :state, :zip
  validates :email, presence: true, uniqueness: true

  enum role: %w(user merchant admin)

  def merchant_orders(status=nil)
    if status.nil?
      Order.distinct.joins(:items).where('items.user_id=?', self.id)
    else
      Order.distinct.joins(:items).where('items.user_id=? AND orders.status=?', self.id, status)
    end
  end

  def merchant_for_order(order)
    !Order.distinct.joins(:items).where('items.user_id=? and orders.id=?', self.id, order.id).empty?
  end

  def total_items_sold
    items
      .joins(:orders)
      .where("orders.status != ?", :cancelled)
      .where("order_items.fulfilled=?", true)
      .sum("order_items.quantity")
  end

  def total_inventory
    items.sum(:inventory)
  end

  def top_shipping(metric, quantity)
    items
      .joins(:orders)
      .joins('join users on orders.user_id=users.id')
      .where("orders.status != ?", :cancelled)
      .where("order_items.fulfilled=?", true)
      .order("count(users.#{metric}) desc")
      .group("users.#{metric}")
      .limit(quantity)
      .pluck("users.#{metric}")
  end

  def top_3_shipping_states
    top_shipping(:state, 3)
  end

  def top_3_shipping_cities
    top_shipping(:city, 3)
  end

  def top_active_user
    User
      .select('users.*, count(orders.id) as order_count')
      .joins(:orders)
      .joins('join order_items on orders.id=order_items.order_id')
      .joins('join items on order_items.item_id=items.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .where('items.user_id = ? AND users.active=?', id, true)
      .group(:id)
      .order('order_count desc')
      .limit(1)
      .first
  end

  def biggest_order
    Order
      .select('orders.*, sum(order_items.quantity) as item_count')
      .joins(:items)
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .where('items.user_id=?', id)
      .order('order_items.quantity desc')
      .group('items.user_id, orders.id, order_items.id')
      .limit(1)
      .first
  end

  def top_buyers(quantity=3)
    User
      .select('users.*, sum(order_items.quantity*order_items.price) as total_spent')
      .joins(:orders)
      .joins('join order_items on orders.id=order_items.order_id')
      .joins('join items on order_items.item_id=items.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .where('items.user_id = ? AND users.active=?', id, true)
      .group(:id)
      .order('total_spent desc')
      .limit(quantity)
  end

  def self.top_sold_merchants_since(since, quantity = 10)
    joins(items: :orders)
      .where(orders: { status: :completed })
      .where('orders.created_at > ?', since)
      .select('users.*, SUM(order_items.quantity) as total_quantity')
      .order('total_quantity DESC')
      .group(:id)
      .distinct
      .limit(quantity)
  end

  def self.top_merchants(quantity)
    select('distinct users.*, sum(order_items.quantity*order_items.price) as total_earned')
      .joins(:items)
      .joins('join order_items on items.id=order_items.item_id')
      .joins('join orders on orders.id=order_items.order_id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .group('orders.id, users.id, order_items.id')
      .order('total_earned desc, users.name')
      .limit(quantity)
  end

  def self.popular_merchants(quantity)
    select('users.*, coalesce(count(order_items.id),0) as total_orders')
      .joins('join items on items.user_id=users.id')
      .joins('join order_items on order_items.item_id=items.id')
      .joins('join orders on orders.id=order_items.order_id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .group(:id)
      .order('total_orders desc, users.name asc')
      .limit(quantity)
  end

  def self.merchant_by_speed(quantity, order)
    select("distinct users.*,
      CASE
        WHEN order_items.updated_at > order_items.created_at THEN coalesce(EXTRACT(EPOCH FROM order_items.updated_at) - EXTRACT(EPOCH FROM order_items.created_at),0)
        ELSE 1000000000 END as time_diff")
      .joins(:items)
      .joins('join order_items on items.id=order_items.item_id')
      .joins('join orders on orders.id=order_items.order_id')
      .where('orders.status != ?', :cancelled)
      .group('orders.id, users.id, order_items.updated_at, order_items.created_at')
      .order("time_diff #{order}")
      .limit(quantity)
  end

  def self.fastest_merchants(quantity)
    merchant_by_speed(quantity, :asc)
  end

  def self.slowest_merchants(quantity)
    merchant_by_speed(quantity, :desc)
  end
end
