# frozen_string_literal: true

# ユーザー認証に関するコントローラ
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      reset_session
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      log_in user
      redirect_to daily_logs_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to pages_top_path, status: :see_other
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end
end
