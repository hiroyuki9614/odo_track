class DownloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user

  def index
    @pdf_exports = PdfExport.recent_first.page(params[:page]).per(20)
    legacy_files = Dir.glob(Rails.root.join('downloads', '*.pdf')).sort_by { |file| File.mtime(file) }.reverse
    @legacy_files = Kaminari.paginate_array(legacy_files).page(params[:legacy_page]).per(20)
  end

  def batch
    @pdf_export = PdfExport.find(params[:id])
    files = Dir.glob(@pdf_export.directory.join('*.pdf')).sort_by { |file| File.basename(file) }
    @files = Kaminari.paginate_array(files).page(params[:page]).per(20)
  end

  def archive
    pdf_export = PdfExport.find(params[:id])
    archive_path = pdf_export.archive_path

    if pdf_export.status == 'completed' && archive_path.present? && File.file?(archive_path)
      send_file archive_path,
                filename: archive_path.basename.to_s,
                type: 'application/zip',
                disposition: 'attachment'
    else
      render plain: 'ZIPファイルが見つかりません', status: :not_found
    end
  end

  def batch_file
    pdf_export = PdfExport.find(params[:id])
    filepath = safe_file_path(pdf_export.directory, params[:filename], '.pdf')

    if filepath && File.file?(filepath)
      send_file filepath,
                filename: filepath.basename.to_s,
                type: 'application/pdf',
                disposition: 'attachment'
    else
      render plain: 'ファイルが見つかりません', status: :not_found
    end
  end

  def show
    requested_filename = params[:filename].to_s
    filename = requested_filename.delete_suffix('.pdf')
    filepath = safe_file_path(Rails.root.join('downloads'), filename, '.pdf')

    if filepath && File.file?(filepath)
      send_file filepath, filename: filepath.basename.to_s, type: 'application/pdf', disposition: 'attachment'
    else
      render plain: 'ファイルが見つかりません', status: :not_found
    end
  end

  private

  def safe_file_path(root, requested_filename, extension)
    requested_filename = requested_filename.to_s
    return unless requested_filename.match?(/\A[^\\\/\0]+\z/)

    filename = requested_filename.delete_suffix(extension)
    return if filename.blank?

    clean_root = root.cleanpath
    filepath = clean_root.join("#{filename}#{extension}").cleanpath
    return unless filepath.dirname == clean_root

    filepath
  end

  def admin_user
    return if current_user.admin?

    redirect_to root_url, status: :see_other
  end
end
