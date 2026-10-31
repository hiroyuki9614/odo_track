# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public demo session sign-in', type: :request do
  let(:password) { 'demo-login-regression-password' }

  it 'allows the shared admin to sign in via the real Devise session endpoint' do
    admin = create(:user,
                   email: 'portfolio-demo-admin@example.com',
                   admin: true,
                   user_name: 'Portfolio Admin',
                   password: password,
                   password_confirmation: password)

    post user_session_path, params: { user: { email: admin.email, password: password } }

    expect(response).to redirect_to(daily_logs_path)
    get '/api/users_for_admin'
    expect(response).to have_http_status(:ok)
  end

  it 'still blocks the shared admin from changing another user after authentication' do
    admin = create(:user,
                   email: 'portfolio-demo-admin@example.com',
                   admin: true,
                   user_name: 'Portfolio Admin',
                   password: password,
                   password_confirmation: password)
    another_user = create(:user, user_name: 'Unrelated User')

    post user_session_path, params: { user: { email: admin.email, password: password } }
    expect(response).to redirect_to(daily_logs_path)

    patch "/api/users_for_admin/#{another_user.id}",
          params: { users_for_admin: { user_name: 'Should not change' } }
    expect(response).to have_http_status(:forbidden)
    expect(another_user.reload.user_name).to eq('Unrelated User')
  end
end
