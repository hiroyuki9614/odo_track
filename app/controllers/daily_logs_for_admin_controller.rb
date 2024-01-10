class DailyLogsForAdminController < ApplicationController
  before_action :authenticate_user!
  def index
    @daily_logs_for_admin = DailyLog.all
  end
end
