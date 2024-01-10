class PagesController < ApplicationController
  def top; end

  def help; end

  def print
    @today = Time.zone.today
    @user = User.find(params[:id])
    @daily_log = DailyLog.kept.user.id
  end
end
