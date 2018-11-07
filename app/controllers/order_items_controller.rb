class OrderItemsController < ApplicationController
  def update
    @order_item = OrderItem.find(params[:order_item_id])
    @order_item.fulfilled = true
    @order_item.save
    @order_item.item.inventory -= @order_item.quantity
    @order_item.item.save

    @order = @order_item.order
    if @order.order_items.where(fulfilled: false).count == 0
      @order.update(status: :completed)
    end

    flash[:success] = "Item fulfilled, good job on the sale!"
    redirect_back(fallback_location: dashboard_orders_path)
  end
end
