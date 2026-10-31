class PagesController < ApplicationController
  def top; end

  def help; end

  def print
    return head :forbidden if public_demo_account?

    @today = Time.zone.today
    @user = User.find(params[:id])
    @daily_log = DailyLog.kept.user.id
  end
end
