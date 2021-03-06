class UsersController < ApplicationController
  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:token] = @user.session_token
      login_user!
      redirect_to cats_url
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to new_users_url
    end
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :password)
  end
end
