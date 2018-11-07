class SessionController < ApplicationController
  def new 
    if current_user
      flash[:info] = 'You are already logged in'
      redirect_to profile_path
    end
  end

  def create 
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if user.active?
        session[:user_id] = user.id
        redirect_to profile_path
      else
        flash[:error] = 'Your account is disabled'
        render :new
      end
    else
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    session[:cart] = nil
    flash[:info] = 'You are logged out'
    redirect_to root_path
  end
end