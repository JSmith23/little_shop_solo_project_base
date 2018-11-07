class UsersController < ApplicationController
  def index
    render file: 'errors/not_found', status: 404 unless current_admin?
    @users = User.all
  end

  def show
    if request.fullpath == '/profile'
      render file: 'errors/not_found', status: 404 unless current_user
      @user = current_user
    else # '/users/:id
      if current_admin?
        @user = User.find(params[:id])
        if @user.merchant?
          redirect_to merchant_path(@user.id)
        end
      else
        render file: 'errors/not_found', status: 404
      end
    end
  end

  def new
    @user = User.new
  end

  def edit
    render file: 'errors/not_found', status: 404 if current_user.nil?
    if current_user
      @user = current_user
      if current_admin? && params[:id]
        @user = User.find(params[:id])
      elsif current_user && params[:id] && current_user.id != params[:id]
        render file: 'errors/not_found', status: 404
      end
    end
  end

  def update
    render file: 'errors/not_found', status: 404 if current_user.nil?
    if current_user && params[:id]
      if current_admin? || (current_user.id == params[:id].to_i)
        @user = User.find(params[:id])

        if current_admin? && params[:toggle]
          if params[:toggle] == 'enable'
            @user.active = true
          elsif params[:toggle] == 'disable'
            @user.active = false
          elsif params[:toggle] == 'role'
            if @user.merchant?
              @user.role = :user
            elsif @user.user?
              @user.role = :merchant
            end
          end

          @user.save

          flash[:success] = 'Profile data was successfully updated.'
          if params[:toggle] && params[:toggle] != 'role' && @user.merchant?
            redirect_to merchants_path
          else
            redirect_to users_path
          end
        else
          if @user.update(user_params)
            flash[:success] = 'Profile data was successfully updated.'
            redirect_to current_admin? ? user_path(@user) : profile_path
          else
            render :edit
          end
        end
      else
        # :nocov:
        # this can't be tested with capybara, it would require a user to manually send a put/patch
        # to a user's edit path, which capybara cannot emulate.
        render file: 'errors/not_found', status: 404
        # :nocov:
      end
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path, notice: 'Welcome to the site!'
    else
      render :new
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :address, :city, :state, :zip)
    end
end
