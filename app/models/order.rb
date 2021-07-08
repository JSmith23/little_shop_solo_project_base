class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status

  def total 
    oi = order_items.pluck("sum(quantity*price)")
    oi.sum
  end

  def self.top_shipping(metric, quantity)
    User
      .joins('join orders on orders.user_id=users.id')
      .joins('join order_items on order_items.order_id=orders.id')
      .where("orders.status != ?", :cancelled)
      .where("order_items.fulfilled=?", true)
      .order("count(users.#{metric}) desc")
      .group("users.#{metric}")
      .limit(quantity)
      .pluck("users.#{metric}")
  end

  def self.top_buyers(quantity)
    User
      .select('users.*, sum(order_items.quantity*order_items.price) as total_spent')
      .joins(:orders)
      .joins('join order_items on orders.id=order_items.order_id')
      .joins('join items on order_items.item_id=items.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .where('users.active=?', true)
      .group(:id)
      .order('total_spent desc')
      .limit(quantity)
  end

  def self.biggest_orders(quantity)
    Order
      .select('orders.*, users.name as user_name, sum(order_items.quantity) as item_count')
      .joins(:items)
      .joins('join users on orders.user_id=users.id')
      .where('orders.status != ?', :cancelled)
      .where('order_items.fulfilled = ?', true)
      .order('item_count desc')
      .group('items.user_id, orders.id, order_items.id, users.id')
      .limit(quantity)
  end
end
