class DownloadsController < ApplicationController
  def index
    @files = Dir.glob(Rails.root.join('downloads', '*'))
  end

  def show
    filename = params[:filename]
    # ファイル名のエンコーディングを確認し、必要に応じて調整
    filepath = Rails.root.join('downloads', "#{filename}.pdf")

    if File.exist?(filepath)
      send_file(filepath, filename: "#{filename}.pdf", type: 'application/pdf', disposition: 'inline')
    else
      render plain: 'ファイルが見つかりません', status: :not_found
    end
  end
end
