# frozen_string_literal: true

class ExportDailyLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, except: %i[show index export_pdf]
  # スプレッドシートの表をpdf化する

  # ダウンロードできるファイル(csv/pdf)の一覧を表示する
  def index
    @users = User.kept.order(created_at: :desc).page params[:page]
  end

  # def export_pdf
  #   @today = Time.zone.today
  #   @first_day = first_day_of_last_month = Date.today.beginning_of_month - 1.month
  #   @last_day = last_day_of_last_month = first_day_of_last_month.end_of_month

  #   user = User.find_by(params[:id])
  #   daily_logs = user.daily_logs.kept.where(created_at: first_day_of_last_month..last_day_of_last_month)
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       # pdfを新規作成。インスタンスを渡す。
  #       pdf = RecordPdf.new(daily_logs, user)
  #       send_data pdf.render,
  #                 filename: "#{user.user_name}_#{Date.today.strftime('%Y%m%d')}.pdf",
  #                 type: 'application/pdf'
  #       # disposition: 'inline' # 画面に表示。外すとダウンロードされる。
  #     end
  #   end
  # end
  def export_pdf
    @first_day = Date.today.beginning_of_month - 1.month
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
    @first_day = first_day_of_last_month = Date.today.beginning_of_month - 1.month
    @last_day = last_day_of_last_month = first_day_of_last_month.end_of_month

    @user = User.find(params[:id])
    @daily_logs = @user.daily_logs.kept.where(created_at: first_day_of_last_month..last_day_of_last_month)
  end
end
