# frozen_string_literal: true

# ユーザーの管理・認証を行うコントローラー
# メール認証とパスワードのハッシュ化など
class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[edit update]

  def index
    @users = User.all.order(created_at: :asc).page params[:page]
  end

  def show; end

  def new
    @user = User.new
  end

  def confirm
    if request.post?
      @user = User.new(user_params)
      session[:user_data] = user_params
    else
      @user = User.new(session[:user_data])
    end
    return unless @user.invalid?

    render :new
  end

  def create
    @user = User.new(user_params)
    return render :new if params[:button] == 'back'

    Rails.logger.info user_params.inspect
    if @user.save
      reset_session
      log_in @user
      redirect_to users_path
    else
      render :confirm
    end
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

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(:user_name,
                                 :email,
                                 :telephone,
                                 :password,
                                 :password_confirmation,
                                 :is_active,
                                 :is_admin)
  end
end

def logged_in_user
  return if logged_in?

  flash[:danger] = 'ログインしてください。'
  redirect_to login_url, status: :see_other
end
