# frozen_string_literal: true

class ExportDailyLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user
  # スプレッドシートの表をpdf化する

  # ダウンロードできるファイル(csv/pdf)の一覧を表示する
  def index
    @users = User.kept.order(created_at: :desc).page params[:page]
  end

  def export_pdf
    # @first_day = Date.today.beginning_of_month - 1.month
    # ポートフォリオ用に今月に設定。　本来は先月分の日報をPDFにする。
    @first_day = Date.today.beginning_of_month
    @last_day = @first_day.end_of_month

    User.kept.find_each do |user|
      daily_logs = user.daily_logs.kept.where(created_at: @first_day..@last_day)
      pdf = RecordPdf.new(daily_logs, user)

      # PDFファイルの名前をユーザーごとに設定
      file_name = "#{user.user_name}_#{Date.today.strftime('%Y%m%d')}.pdf"

      # PDFをファイルとして保存するか、直接レスポンスとして出 力する
      # 例: ファイルとして保存
      save_path = Rails.root.join('downloads')
      FileUtils.mkdir_p(save_path) unless Dir.exist?(save_path)

      File.open(save_path.join(file_name), 'wb') do |file|
        file.write(pdf.render)
      end
      File.open(Rails.root.join('downloads', file_name), 'wb') do |file|
        file.write(pdf.render, type: 'application/pdf')
      end
    end

    # または、直接レスポンスとして出力
    # send_data pdf.render, filename: file_name, type: 'application/pdf', disposition: 'inline'
  end

  def show
    @today = Time.zone.today
    # ポートフォリオ用に今月に設定。　本来は先月分の日報をPDFにする。
    @first_day = Date.today.beginning_of_month
    @last_day = last_day_of_last_month = first_day_of_last_month.end_of_month

    @user = User.find(params[:id])
    @daily_logs = @user.daily_logs.kept.where(created_at: first_day_of_last_month..last_day_of_last_month)
  end

  private

  def admin_user
    return if current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
