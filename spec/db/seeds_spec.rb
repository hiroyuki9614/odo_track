# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe 'database seeds' do
  it 'keeps Faker vehicle text within Vehicle validation limits' do
    allow(Faker::Vehicle).to receive(:model).and_return('M' * 64)
    allow(Faker::Vehicle).to receive(:manufacture).and_return('N' * 64)

    expect { load Rails.root.join('db/seeds.rb') }.not_to raise_error

    expect(Vehicle.pluck(:vehicle_name, :manufacture)).to all(
      satisfy do |values|
        values[0].length <= Vehicle::VEHICLE_NAME_MAX_LENGTH &&
          values[1].length <= Vehicle::MANUFACTURE_MAX_LENGTH
      end
    )
  end
end
