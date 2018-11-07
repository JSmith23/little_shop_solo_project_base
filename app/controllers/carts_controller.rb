class CartsController < ApplicationController
  include ActionView::Helpers::TextHelper

  def index
    @items = Item.where(id: @cart.contents.keys)
  end

  def update
    item = Item.find(params[:item_id])
    if params[:quantity] == 'more'
      if @cart.count_of(item.id)+1 <= item.inventory
        @cart.add_item(item.id)
        flash[:success] = "Added another #{item.name} to your cart"
      else
        flash[:warning] = "Cannot add another #{item.name} to your cart, merchant doesn't have enough inventory"
      end
    elsif params[:quantity] == 'less'
      @cart.remove_item(item.id)
      flash[:success] = "Removed #{item.name} from your cart"
    elsif params[:quantity] == 'none'
      @cart.remove_all_item(item.id)
      flash[:success] = "Removed entire quantity of #{item.name} from your cart"
    end
    session[:cart] = @cart.contents
    redirect_back(fallback_location: items_path)
  end

  def empty
    session[:cart] = nil
    @cart = Cart.new({})
    redirect_to carts_path
  end
end