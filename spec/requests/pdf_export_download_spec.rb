# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF export and download', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin) { create(:user, admin: true, user_name: 'PDF管理者') }
  let(:download_dir) { Rails.root.join('downloads') }
  let(:created_directories) { [] }

  before do
    FileUtils.mkdir_p(download_dir)
    sign_in admin
  end

  after do
    created_directories.each { |path| FileUtils.rm_rf(path) }
  end

  it 'creates a monthly export batch with individual PDFs and a ZIP archive' do
    rendered_pdf = "%PDF-1.4\nrequest-spec\n"
    pdf = instance_double(RecordPdf, render: rendered_pdf)
    create(:daily_log, user_id: admin.id, created_at: Time.zone.local(2026, 9, 10, 9, 0))

    allow(User).to receive(:kept).and_return(User.where(id: admin.id))
    allow(RecordPdf).to receive(:new).and_return(pdf)

    # 2026-08-31 15:30 UTC is 2026-09-01 00:30 in the configured Tokyo zone.
    travel_to Time.utc(2026, 8, 31, 15, 30) do
      post export_pdf_path, params: { month: '2026-09' }

      pdf_export = PdfExport.order(:id).last
      created_directories << pdf_export.directory
      expected_path = pdf_export.directory.join("user_#{admin.id}_PDF管理者_2026-09.pdf")

      expect(response).to redirect_to(download_batch_path(pdf_export))
      expect(pdf_export.target_month).to eq(Date.new(2026, 9, 1))
      expect(pdf_export.status).to eq('completed')
      expect(pdf_export.pdf_count).to eq(1)
      expect(File.binread(expected_path)).to eq(rendered_pdf)
      expect(File.file?(pdf_export.archive_path)).to be(true)
    end
  end

  it 'skips users who have no kept daily logs in the target month' do
    with_logs = create(:user, user_name: '日報あり')
    without_logs = create(:user, user_name: '日報なし')
    create(:daily_log, user_id: with_logs.id, created_at: Time.zone.local(2026, 9, 15, 9, 0))

    rendered_pdf = "%PDF-1.4\nonly-user-with-logs\n"
    pdf = instance_double(RecordPdf, render: rendered_pdf)
    allow(User).to receive(:kept).and_return(User.where(id: [with_logs.id, without_logs.id]))
    allow(RecordPdf).to receive(:new).and_return(pdf)

    post export_pdf_path, params: { month: '2026-09' }

    pdf_export = PdfExport.order(:id).last
    created_directories << pdf_export.directory

    expect(response).to redirect_to(download_batch_path(pdf_export))
    expect(pdf_export.status).to eq('completed')
    expect(pdf_export.pdf_count).to eq(1)
    expect(File.file?(pdf_export.directory.join("user_#{with_logs.id}_日報あり_2026-09.pdf"))).to be(true)
    expect(File.file?(pdf_export.directory.join("user_#{without_logs.id}_日報なし_2026-09.pdf"))).to be(false)
    expect(RecordPdf).to have_received(:new).once
  end

  it 'serves a batch ZIP as an attachment' do
    pdf_export = PdfExport.create!(target_month: Date.new(2026, 9, 1), status: 'completed', created_by: admin)
    created_directories << pdf_export.directory
    FileUtils.mkdir_p(pdf_export.directory)
    zip_filename = "odo_track_2026-09_export_#{pdf_export.id}.zip"
    zip_path = pdf_export.directory.join(zip_filename)
    File.binwrite(zip_path, "PK\x03\x04zip-spec")
    pdf_export.update!(zip_filename: zip_filename)

    get download_batch_archive_path(pdf_export)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/zip')
    expect(response.headers['Content-Disposition']).to include('attachment')
    expect(response.headers['Content-Disposition']).to include(zip_filename)
  end

  it 'serves a batch PDF as an attachment' do
    pdf_export = PdfExport.create!(target_month: Date.new(2026, 9, 1), status: 'completed', created_by: admin)
    created_directories << pdf_export.directory
    FileUtils.mkdir_p(pdf_export.directory)
    filename = 'batch-user_1_2026-09.pdf'
    File.binwrite(pdf_export.directory.join(filename), "%PDF-1.4\nbatch-spec\n")

    get download_batch_file_path(pdf_export, File.basename(filename, '.pdf'))

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/pdf')
    expect(response.headers['Content-Disposition']).to include('attachment')
    expect(response.headers['Content-Disposition']).to include(filename)
  end

  it 'paginates individual PDFs in a batch at 20 files per page' do
    pdf_export = PdfExport.create!(target_month: Date.new(2026, 9, 1), status: 'completed', created_by: admin, pdf_count: 21)
    created_directories << pdf_export.directory
    FileUtils.mkdir_p(pdf_export.directory)

    21.times do |index|
      filename = format('user_%02d_2026-09.pdf', index + 1)
      File.binwrite(pdf_export.directory.join(filename), "%PDF-1.4\n")
    end

    get download_batch_path(pdf_export)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('user_01_2026-09.pdf')
    expect(response.body).to include('user_20_2026-09.pdf')
    expect(response.body).not_to include('user_21_2026-09.pdf')
  end
end
