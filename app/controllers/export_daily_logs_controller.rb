# frozen_string_literal: true

class ExportDailyLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @users = User.kept.order(created_at: :desc).page params[:page]
  end

  def export_pdf
    pdf_export = PdfExport.create!(
      target_month: requested_target_month,
      status: 'processing',
      created_by: current_user
    )

    PdfExports::Generate.new(pdf_export: pdf_export).call

    redirect_to download_batch_path(pdf_export),
                notice: "#{pdf_export.target_month.strftime('%Y年%-m月')}のPDFを#{pdf_export.pdf_count}件作成しました。"
  rescue Date::Error
    redirect_to export_daily_logs_path, alert: '対象月の形式が正しくありません。'
  rescue ActiveRecord::RecordInvalid, RuntimeError => e
    Rails.logger.error("PDF export failed: #{e.class}")
    redirect_to downloads_path, alert: 'PDFの作成に失敗しました。'
  end

  def show
    @today = Time.zone.today
    @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month

    @user = User.find(params[:id])
    @daily_logs = @user.daily_logs.kept.where(created_at: @first_day.beginning_of_day..@last_day.end_of_day)
  end

  private

  def requested_target_month
    return Date.current.beginning_of_month if params[:month].blank?

    Date.strptime(params[:month], '%Y-%m').beginning_of_month
  end

  def admin_user
    return if current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
