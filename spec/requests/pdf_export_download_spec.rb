# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF export and download', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin) { create(:user, admin: true, user_name: 'PDF管理者') }
  let(:download_dir) { Rails.root.join('downloads') }
  let(:created_files) { [] }

  before do
    FileUtils.mkdir_p(download_dir)
    sign_in admin
  end

  after do
    created_files.each { |path| FileUtils.rm_f(path) }
  end

  it 'uses the Rails timezone, writes the PDF, and redirects to the download list' do
    rendered_pdf = "%PDF-1.4\nrequest-spec\n"
    pdf = instance_double(RecordPdf, render: rendered_pdf)

    allow(User).to receive(:kept).and_return(User.where(id: admin.id))
    allow(RecordPdf).to receive(:new).and_return(pdf)

    # 2026-08-31 15:30 UTC is 2026-09-01 00:30 in the configured Tokyo zone.
    travel_to Time.utc(2026, 8, 31, 15, 30) do
      expected_path = download_dir.join('PDF管理者_20260901.pdf')
      created_files << expected_path

      get export_pdf_path

      expect(response).to redirect_to(downloads_path)
      expect(File.binread(expected_path)).to eq(rendered_pdf)
    end
  end

  it 'serves generated PDFs as an attachment' do
    filename = "request-spec-#{SecureRandom.hex(6)}.pdf"
    filepath = download_dir.join(filename)
    created_files << filepath
    File.binwrite(filepath, "%PDF-1.4\ndownload-spec\n")

    get download_path(File.basename(filename, '.pdf'))

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/pdf')
    expect(response.headers['Content-Disposition']).to include('attachment')
    expect(response.headers['Content-Disposition']).to include(filename)
  end

  it 'renders canonical download links without duplicating the pdf extension' do
    filename = "link-spec-#{SecureRandom.hex(6)}.pdf"
    filepath = download_dir.join(filename)
    created_files << filepath
    File.binwrite(filepath, "%PDF-1.4\nlink-spec\n")

    get downloads_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(download_path(File.basename(filename, '.pdf')))
    expect(response.body).not_to include("#{filename}.pdf")
  end
end
