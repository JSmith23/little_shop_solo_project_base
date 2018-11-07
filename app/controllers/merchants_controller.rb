class MerchantsController < ApplicationController
  def index
    if current_admin?
      @merchants = User.where(role: :merchant).order(:name)
    else
      @merchants = User.where(role: :merchant, active: true).order(:name)
    end
    @top_sold_merchants_for_past_month = User.top_sold_merchants_since(1.month.ago)
    @top_fulfilled_merchants_for_past_month = User.top_fulfilled_merchants_since(1.month.ago)
  end

  def show
    render file: 'errors/not_found', status: 404 unless current_user

    @merchant = User.find(params[:id])
    if current_admin?
      @orders = current_user.merchant_orders
      if @merchant.user?
        redirect_to user_path(@merchant)
      end
    elsif current_user != @merchant
      render file: 'errors/not_found', status: 404
    end
  end
end
