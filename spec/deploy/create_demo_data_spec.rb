# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'deploy/create_demo_data.rb' do
  let(:demo_password) { 'demo-seed-regression-password' }
  let(:seed_script) { Rails.root.join('deploy/create_demo_data.rb') }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('DEMO_USER_PASSWORD').and_return(demo_password)
    allow(ENV).to receive(:fetch).with('DEMO_ADMIN_PASSWORD').and_return(demo_password)
  end

  it 'associates the sample vehicle with both demo users idempotently' do
    expect { load seed_script }.to change(FavoriteVehicle, :count).by(2)
    expect { load seed_script }.not_to change(FavoriteVehicle, :count)

    users = User.where(email: [
      'portfolio-demo-user@example.com',
      'portfolio-demo-admin@example.com'
    ])
    vehicle = Vehicle.find_by!(vehicle_name: 'Portfolio Demo Car', number: '1001')

    expect(users.count).to eq(2)
    users.each do |user|
      expect(user.favorite_vehicles.exists?(vehicle_id: vehicle.id)).to be(true)
    end
  end
end
