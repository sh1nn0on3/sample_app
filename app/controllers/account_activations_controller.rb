class AccountActivationsController < ApplicationController
  before_action :authenticate_user!, only: [:edit]
  before_action :find_user_by_email, only: [:edit]
  
    def edit
      @user = find_user_by_email
      if @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
        @user.activate
        flash[:success] = "Account activated!"
        redirect_to @user
      else
        flash[:danger] = "Invalid activation link"
        redirect_to root_url
      end
    end

    private

    def find_user_by_email 
      User.find_by(email: params[:email])
    end
end
