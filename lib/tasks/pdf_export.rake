namespace :pdf_export do
  desc 'ユーザー全員の日報のPDFを作成する'
  task export_all: :environment do
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
    end
  end
end
