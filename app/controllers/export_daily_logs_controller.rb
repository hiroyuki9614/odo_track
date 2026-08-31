# frozen_string_literal: true

class ExportDailyLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @users = User.kept.order(created_at: :desc).page params[:page]
  end

  def export_pdf
    first_day = Date.current.beginning_of_month
    last_day = first_day.end_of_month
    period = first_day.beginning_of_day..last_day.end_of_day
    save_path = Rails.root.join('downloads')
    FileUtils.mkdir_p(save_path)

    generated_count = 0

    User.kept.find_each do |user|
      daily_logs = user.daily_logs.kept.where(created_at: period)
      pdf = RecordPdf.new(daily_logs, user)
      safe_user_name = user.user_name.to_s.gsub(%r{[\\/\0]}, '_').presence || "user_#{user.id}"
      file_name = "#{safe_user_name}_#{Date.current.strftime('%Y%m%d')}.pdf"

      File.binwrite(save_path.join(file_name), pdf.render)
      generated_count += 1
    end

    redirect_to downloads_path,
                notice: "PDFを#{generated_count}件作成しました。ダウンロードするファイルを選択してください。"
  end

  def show
    @today = Time.zone.today
    @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month

    @user = User.find(params[:id])
    @daily_logs = @user.daily_logs.kept.where(created_at: @first_day.beginning_of_day..@last_day.end_of_day)
  end

  private

  def admin_user
    return if current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
