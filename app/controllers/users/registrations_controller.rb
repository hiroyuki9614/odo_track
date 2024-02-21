# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, only: [:cancel]
  prepend_before_action :authenticate_scope!, only: %i[edit update destroy]
  prepend_before_action :set_minimum_password_length, only: %i[new edit]
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :admin_user, only: %i[edit destroy update]
  # protect_from_forgery

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super
  end

  # GET /resource/edit
  def edit
    if by_admin_user?(params)
      self.resource = resource_class.to_adapter.get!(params[:id])
      render :edit
    else
      authenticate_scope!
      super
    end
  end

  # PUT /resource
  def update
    super
  end
  ## 管理者は全てのidを取得できる。
  #   Rails.logger.info "Before update: Current user id = #{current_user.id}, session: #{session.inspect}"
  #   self.resource = if by_admin_user?(params)
  #                     resource_class.to_adapter.get!(params[:id])
  #                   else
  #                     resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
  #                   end

  #   prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

  #   # 管理者はパスワード無しで編集を実行できる。
  #   resource_updated = if by_admin_user?(params)
  #                        update_resource_without_password(resource, account_update_params)
  #                        Rails.logger.info "After update: Current user id = #{current_user.id}, session: #{session.inspect}"
  #                      else
  #                        Rails.logger.info 'Updating with password'
  #                        update_resource(resource, account_update_params)
  #                      end

  #   # 管理者のみパスワード無しで編集できる設定。
  #   # resource_updated = if by_admin_user?(params)
  #   #                            update_resource_without_password(resource, account_update_params)
  #   #                            Rails.logger.info "After update: Current user id = #{current_user.id}, session: #{session.inspect}"
  #   #                          else
  #   #                            Rails.logger.info 'Updating with password'
  #   #                            update_resource(resource, account_update_params)
  #   #                          end

  #   yield resource if block_given?
  #   if resource_updated
  #     set_flash_message_for_update(resource, prev_unconfirmed_email)
  #     bypass_sign_in resource, scope: resource_name unless by_admin_user?(params)

  #     respond_with resource, location: after_update_path_for(resource)
  #   # if resource_updated
  #   #   set_flash_message_for_update(resource, prev_unconfirmed_email)
  #   #   Rails.logger.info "After update resource method: Current user id = #{current_user.id}, session: #{session.inspect}"
  #   #   bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
  #   #   # 管理者がユーザー情報を変更してもユーザーのログインを維持する。
  #   #   bypass_sign_in resource, scope: resource_name unless by_admin_user?(params)
  #   #   Rails.logger.info "Before respond_with: Current user id = #{current_user.id}, session: #{session.inspect}"
  #   #   respond_with resource, location: after_update_path_for(resource)
  #   else
  #     clean_up_passwords resource
  #     set_minimum_password_length
  #     respond_with resource
  #   end
  # end
  # end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def by_admin_user?(_params)
    user_signed_in? && current_user.admin?
  end

  # パスワード無しで編集を実行できる。
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def update_resource_without_password(resource, params)
    resource.update_without_password(params)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: %i[user_name email telephone])
  end

  # The path used after sign up.
  def after_sign_up_path_for(_daily_logs_path)
    super(resource)
  end

  def after_update_path_for(resource)
    users_path(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  def admin_user
    return if current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
