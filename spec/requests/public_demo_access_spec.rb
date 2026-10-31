# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public demo account access', type: :request do
  let!(:demo_admin) do
    create(:user, email: 'portfolio-demo-admin@example.com', admin: true, user_name: 'Demo Admin')
  end
  let!(:demo_user) do
    create(:user, email: 'portfolio-demo-user@example.com', admin: false, user_name: 'Demo User')
  end
  let!(:private_user) do
    create(:user, email: 'private-owner@example.test', admin: false, user_name: 'Other User')
  end

  before { sign_in(demo_admin) }

  it 'shows only the two demo users in the admin listing' do
    get '/api/users_for_admin'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(demo_admin.email)
    expect(response.body).to include(demo_user.email)
    expect(response.body).not_to include(private_user.email)
  end

  it 'does not let a publicly shared administrator edit users' do
    patch "/api/users_for_admin/#{private_user.id}",
          params: { users_for_admin: { user_name: 'Unexpected change' } }

    expect(response).to have_http_status(:forbidden)
    expect(private_user.reload.user_name).to eq('Other User')
  end

  it 'does not expose unrelated PDF exports to the public demo admin' do
    get '/downloads'

    expect(response).to have_http_status(:forbidden)
  end

  it 'does not allow the public demo admin to open another user edit page' do
    get edit_other_user_registration_path(private_user)

    expect(response).to have_http_status(:not_found)
  end
end
