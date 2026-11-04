# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public demo credentials on login page', type: :request do
  it 'loads the existing public demo credentials card on the login page' do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('login-demo-credentials')
    expect(response.body).to include('demo-login-heading')
    expect(response.body).to include(root_path)
  end
end
