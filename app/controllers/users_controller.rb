class UsersController < ApplicationController
  before_action :authorized, only: %i[show edit]

  def new
    if !logged_in?
      @user = User.new
    else
      redirect_to login_path
    end
  end

  def create
    if logged_in?
      redirect_to login_path, flash: {success: 'Cant create new user while logged in'}
    end

    @user = User.new(user_params)

    if @user.valid?
      @user.save
      redirect_to login_path, flash: {success: 'User Registered Successfully. Please Login to continue.'}
    else
      redirect_to signup_path,flash: {success: 'Email already exists'}
    end
  end

  def show
    if !User.exists?(params[:id])
      redirect_to login_path,flash: {success: 'Email already exists'}
    else
      @user = User.find(params[:id])
      if session[:user_id] != @user.id
        redirect_to login_path,flash: {success: 'User not authorized'}
      end
      @city = request.location.city
      @restaurants = Restaurant.all
    end
  end

  def edit
    if !User.exists?(params[:id])
      redirect_to login_path,flash: {success: 'User not authorized'}
    else
      @user = User.find(params[:id])
      if session[:user_id] != @user.id
        redirect_to login_path,flash: {success: 'User not authorized'}
      end
    end
  end

  def update
    if !logged_in?
      redirect_to login_path

    else
      @user = User.find(get_user[:id])
      if @user.update(user_params)
        redirect_to @user
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def appointments
    if !User.exists?(params[:id])
      redirect_to login_path,flash: {success: 'User not authorized'}
    else
      @user = User.find(params[:id])
      if session[:user_id] != @user.id
        redirect_to login_path,flash: {success: 'User not authorized'}
      end
      @book = Book.where(user_id: current_user.id)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :isadmin, :latitude,
                                 :longitude)
  end

  def get_user
    params.permit(:id)
  end
end
