class DownloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @files = Dir.glob(Rails.root.join('downloads', '*'))
  end

  def show
    filename = params[:filename].to_s
    return render plain: 'ファイルが見つかりません', status: :not_found unless filename.match?(/\A[^\\\/\0]+\z/)

    filepath = Rails.root.join('downloads', "#{filename}.pdf").cleanpath
    download_root = Rails.root.join('downloads').cleanpath
    return render plain: 'ファイルが見つかりません', status: :not_found unless filepath.dirname == download_root

    if File.exist?(filepath)
      send_file(filepath, filename: "#{filename}.pdf", type: 'application/pdf', disposition: 'inline')
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
