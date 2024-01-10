# frozen_string_literal: true

class UsersForAdminController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def print_index
    @users = User.where(discarded_at: nil).order(created_at: :asc).page params[:page]
  end

  def print
    @user = User.find(params[:id])
    @daily_log = @user.daily_logs.kept
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
