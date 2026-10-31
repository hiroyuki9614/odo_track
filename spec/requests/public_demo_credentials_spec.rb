# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public demo credentials', type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
  end

  it 'shows both demo roles and their deployment-provided credentials on the top page' do
    allow(ENV).to receive(:[]).with('DEMO_ADMIN_PASSWORD').and_return('test-only-admin-password')
    allow(ENV).to receive(:[]).with('DEMO_USER_PASSWORD').and_return('test-only-user-password')

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('採用ご担当者様向け デモログイン')
    expect(response.body).to include('portfolio-demo-admin@example.com')
    expect(response.body).to include('portfolio-demo-user@example.com')
    expect(response.body).to include('test-only-admin-password')
    expect(response.body).to include('test-only-user-password')
    expect(response.body).to include('/auth/login')
  end

  it 'does not render partial credentials if either password is missing' do
    allow(ENV).to receive(:[]).with('DEMO_ADMIN_PASSWORD').and_return(nil)
    allow(ENV).to receive(:[]).with('DEMO_USER_PASSWORD').and_return('test-only-user-password')

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('デモログイン情報は現在準備中です')
    expect(response.body).not_to include('test-only-user-password')
  end

  it 'HTML-escapes credentials sourced from the environment' do
    allow(ENV).to receive(:[]).with('DEMO_ADMIN_PASSWORD').and_return('<script>alert(1)</script>')
    allow(ENV).to receive(:[]).with('DEMO_USER_PASSWORD').and_return('test-only-user-password')

    get root_path

    expect(response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    expect(response.body).not_to include('<script>alert(1)</script>')
  end
end
