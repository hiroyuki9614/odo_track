# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :protect_public_demo_mutations

  PUBLIC_DEMO_EMAILS = %w[
    portfolio-demo-admin@example.com
    portfolio-demo-user@example.com
  ].freeze
  PUBLIC_DEMO_ADMIN_EMAIL = 'portfolio-demo-admin@example.com'

  protected

  def public_demo_account?
    user_signed_in? && PUBLIC_DEMO_EMAILS.include?(current_user.email)
  end

  def public_demo_admin?
    user_signed_in? && current_user.email == PUBLIC_DEMO_ADMIN_EMAIL
  end

  def public_demo_users
    User.where(email: PUBLIC_DEMO_EMAILS)
  end

  def public_demo_logs
    DailyLog.where(user_id: public_demo_users.select(:id))
  end

  def public_demo_vehicles
    Vehicle.where(vehicle_name: 'Portfolio Demo Car', number: '1001')
  end

  # The public admin may explore the UI without rewriting the shared database.
  # Normal accounts retain existing permissions. Logout remains possible.
  def protect_public_demo_mutations
    return unless public_demo_account?

    is_session_auth_action = devise_controller? && controller_name == 'sessions' &&
                             %w[create destroy].include?(action_name)
    if public_demo_admin? && !request.get? && !request.head? && !is_session_auth_action
      head :forbidden
    elsif devise_controller? && controller_name == 'registrations' &&
          %w[update destroy].include?(action_name)
      head :forbidden
    end
  end

  def after_sign_in_path_for(_resource)
    daily_logs_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[user_name email telephone])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[user_name email telephone])
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
