class DownloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @files = Dir.glob(Rails.root.join('downloads', '*.pdf')).sort_by { |file| File.mtime(file) }.reverse
  end

  def show
    requested_filename = params[:filename].to_s
    return render plain: 'ファイルが見つかりません', status: :not_found unless requested_filename.match?(/\A[^\\\/\0]+\z/)

    filename = requested_filename.delete_suffix('.pdf')
    return render plain: 'ファイルが見つかりません', status: :not_found if filename.blank?

    download_root = Rails.root.join('downloads').cleanpath
    filepath = download_root.join("#{filename}.pdf").cleanpath
    return render plain: 'ファイルが見つかりません', status: :not_found unless filepath.dirname == download_root

    if File.file?(filepath)
      send_file(filepath, filename: filepath.basename.to_s, type: 'application/pdf', disposition: 'attachment')
    else
      render plain: 'ファイルが見つかりません', status: :not_found
    end
  end

  private

  def admin_user
    return if current_user.admin?

    redirect_to root_url, status: :see_other
  end
end
