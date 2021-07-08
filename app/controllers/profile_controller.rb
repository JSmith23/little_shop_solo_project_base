class ProfileController < ApplicationController
  def edit
    render file: 'errors/not_found', status: 404 unless current_user
    @user = current_user
  end

  def orders
    render file: 'errors/not_found', status: 404 unless current_user
    @user = current_user
    @orders = @user.orders.where.not(status: :disabled).order(created_at: :desc)
    render :'orders/index'
  end
end