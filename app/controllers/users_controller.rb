# frozen_string_literal: true

# ユーザーのお気に入り管理を行うコントローラー
class UsersController < ApplicationController
  before_action :authenticate_user!
  # before_action :admin_user, only: %i[index destroy]

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:button] == 'back'
      @user.attributes = session[:user_data]
      render :edit and return
    end
    if @user.update(user_params)
      redirect_to users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:user_name,
                                 :email,
                                 :telephone,
                                 :password,
                                 :password_confirmation,
                                 :is_active)
  end

  def admin_user
    return if user_signed_in? && current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
