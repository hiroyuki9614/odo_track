# frozen_string_literal: true

module PdfExports
  class Generate
    def initialize(pdf_export:, users: User.kept)
      @pdf_export = pdf_export
      @users = users
    end

    def call
      prepare_directory
      generated_paths = []

      each_user do |user|
        daily_logs = daily_logs_for(user)
        next if daily_logs.none?

        generated_paths << generate_pdf(user, daily_logs)
      end

      archive_filename = build_archive(generated_paths)
      pdf_export.update!(
        status: 'completed',
        pdf_count: generated_paths.size,
        zip_filename: archive_filename
      )
      pdf_export
    rescue StandardError
      pdf_export.update_column(:status, 'failed') if pdf_export.persisted?
      raise
    end

    private

    attr_reader :pdf_export, :users

    def prepare_directory
      FileUtils.rm_rf(pdf_export.directory)
      FileUtils.mkdir_p(pdf_export.directory)
    end

    def each_user(&block)
      if users.respond_to?(:find_each)
        users.find_each(&block)
      else
        users.each(&block)
      end
    end

    def daily_logs_for(user)
      user.daily_logs.kept.where(created_at: target_period)
    end

    def generate_pdf(user, daily_logs)
      pdf = RecordPdf.new(daily_logs, user)
      path = pdf_export.directory.join(pdf_filename(user))
      File.binwrite(path, pdf.render)
      path
    end

    def target_period
      @target_period ||= pdf_export.target_month.beginning_of_day..pdf_export.target_month.end_of_month.end_of_day
    end

    def pdf_filename(user)
      safe_user_name = user.user_name.to_s.gsub(%r{[\\/\0]}, '_').presence || 'unknown'
      "user_#{user.id}_#{safe_user_name}_#{pdf_export.target_month.strftime('%Y-%m')}.pdf"
    end

    def build_archive(generated_paths)
      return if generated_paths.empty?

      filename = "odo_track_#{pdf_export.target_month.strftime('%Y-%m')}_export_#{pdf_export.id}.zip"
      archive_path = pdf_export.directory.join(filename)
      file_names = generated_paths.map { |path| path.basename.to_s }

      success = system('zip', '-q', archive_path.to_s, *file_names, chdir: pdf_export.directory.to_s)
      raise 'PDF ZIP archive could not be created' unless success && File.file?(archive_path)

      filename
    end
  end
end
