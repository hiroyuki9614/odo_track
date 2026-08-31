class DailyLogsForAdminController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user
  def index
    @daily_logs_for_admin = DailyLog.all
  end

  private

  def admin_user
    return if current_user.admin?

    redirect_to root_url, status: :see_other
  end
end
