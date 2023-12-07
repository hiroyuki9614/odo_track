require 'googleauth'
require 'google_drive'

class ExportDailyLogsController < ApplicationController
  # スプレッドシートをgoogledriveに出力する
  def create_spreadsheet
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: '948718533666-p97dgh1i0nle94o53bcs1cbdpbahk8a7.apps.googleusercontent.com',
      client_secret: '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',
      scope: [
        'https://www.googleapis.com/auth/drive',
        'https://spreadsheets.google.com/feeds/'
      ],
      redirect_uri: 'http://localhost:3000/export_daily_logs/create_spreadsheet'
    )

    if params[:code].nil?
      # ユーザーを認証URLへリダイレクト
      redirect_to credentials.authorization_uri.to_s, allow_other_host: true
    else
      credentials.code = params[:code]
      credentials.fetch_access_token!
      session = GoogleDrive::Session.from_credentials(credentials)

      # スプレッドシートにアクセスして編集
      spreadsheet = session.spreadsheet_by_key('1ZIvj8dQSb0hC-FVZ26WZCpZY7KPchnRDMPilCrvb-BU')
      worksheet = spreadsheet.worksheet_by_title('シート1')
      worksheet[1, 1] = 'Hello World'
      worksheet.save
    end
  end

  # スプレッドシートの表をpdf化する
  def export_to_pdf; end

  # ダウンロードできるファイル(csv/pdf)の一覧を表示する
  def index; end
end
