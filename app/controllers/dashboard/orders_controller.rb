class Dashboard::OrdersController < ApplicationController
  def index
    @orders = current_user.merchant_orders(:pending)
    # render :'orders/index'
  end
end