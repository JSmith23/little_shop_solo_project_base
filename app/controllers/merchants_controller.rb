class MerchantsController < ApplicationController
  def index
    if current_admin?
      @merchants = User.where(role: :merchant).order(:name)
    else
      @merchants = User.where(role: :merchant, active: true).order(:name)
    end
    @top_sold_merchants_for_past_month = User.top_sold_merchants_since(1.month.ago)
    @top_fulfilled_merchants_for_past_month = User.top_fulfilled_merchants_since(1.month.ago)
    if current_user.present?
      @top_fastest_merchants_in_user_state = User.top_fastest_merchants_in(state: current_user.state)
      @top_fastest_merchants_in_user_city = User.top_fastest_merchants_in(city: current_user.city)
    end
  end

  def show
    render file: 'errors/not_found', status: 404 unless current_user

    @merchant = User.find(params[:id])
    if current_admin?
      @orders = current_user.merchant_orders
      if @merchant.user?
        redirect_to user_path(@merchant.path_keys)
      end
    elsif current_user != @merchant
      render file: 'errors/not_found', status: 404
    end
  end
end
