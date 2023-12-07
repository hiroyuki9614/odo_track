# frozen_string_literal: true

class AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @users = User.where(discarded_at: nil).order(created_at: :asc).page params[:page]
  end

  def discarded_index
    @users = User.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
  end

  def discarded_daily_logs_index
    @daily_logs = DailyLog.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def edit_confirm
    if request.patch?
      @user = User.find(params[:id])
      session[:user_data] = user_params
      @user.attributes = user_params
    else
      # ここでセッションから取得したデータを属性にセット
      @user = User.new(session[:user_data])
    end
    return unless @user.invalid?

    render :edit
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

  def make_admin
    @user = User.find(params[:id])
    @user
  end

  def daily_log_destroy
    @daily_log = DailyLog.find(params[:id])
    @daily_log.destroy
    redirect_to discarded_daily_log_path, status: :see_other
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, status: :see_other
  end

  def user_delete
    @user = User.find(params[:id])
    @user.discard
    redirect_to admin_index_path, status: :see_other
  end

  def user_undelete
    @user = User.find(params[:id])
    @user.undiscard
    redirect_to admin_index_path, status: :see_other
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
