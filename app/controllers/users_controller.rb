class UsersController < ApplicationController

  # before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :set_user, only: %i[show edit update destroy]
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.select(:name, :email , :created_at).paginate(page: params[:page])
  end

  def show
  # @user đã được lấy bởi before_action :set_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = I18n.t('check_email_to_activate_account')
      redirect_to root_url

    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    # @user đã được lấy bởi before_action :set_user
  end

  def update
    # @user đã được lấy bởi before_action :set_user
    if @user.update(user_params)
      flash[:success] = I18n.t('profile_updated')
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    # @user đã được lấy bởi before_action :set_user
    flash[:success] = I18n.t('user_deleted')
    redirect_to users_url, status: :see_other
  end

  private

    def set_user
      @user = User.find_by(id: params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = I18n.t('please_log_in')
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user&.admin?
    end
end
