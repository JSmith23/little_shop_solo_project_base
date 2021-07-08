class Dashboard::ItemsController < ApplicationController
  def index 
    render file: 'errors/not_found', status: 404 unless current_user
    @items = Item.where(user: current_user)
    render :'items/index'
  end
end