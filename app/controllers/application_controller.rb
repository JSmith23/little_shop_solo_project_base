class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :build_cart

  helper_method :current_user, :current_admin?

  def current_user
    @current_user_lookup ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def build_cart
    @cart ||= Cart.new(session[:cart])
  end
end
