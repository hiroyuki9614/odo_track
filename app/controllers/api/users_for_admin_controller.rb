# frozen_string_literal: true

module Api
  class UsersForAdminController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_user

    def index
      @users = User.where(discarded_at: nil).order(created_at: :asc).page params[:page]
      @discarded_users = User.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
      render json: {
        users: ActiveModelSerializers::SerializableResource.new(@users, each_serializer: UserSerializer),
        discarded_users: ActiveModelSerializers::SerializableResource.new(@discarded_users,
                                                                          each_serializer: UserSerializer)
      }
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        render json: @user, status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        render json: @user, status: :no_content
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def delete
      @user = User.find(params[:id])
      if @user.discard
        render json: @user, status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def undelete
      @user = User.find(params[:id])
      if @user.undiscard
        render json: @user, status: :ok
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:users_for_admin).permit(:user_name,
                                              :email,
                                              :telephone,
                                              :password,
                                              :password_confirmation,
                                              :admin,
                                              :discarded_at)
    end

    def admin_user
      return if user_signed_in? && current_user.admin?

      flash[:alert] = 'その操作は権限が無いため実行できません。'
      redirect_to(root_url, status: :see_other)
    end
  end
end
