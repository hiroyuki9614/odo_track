# frozen_string_literal: true

demo_user_password = ENV.fetch('DEMO_USER_PASSWORD')
demo_admin_password = ENV.fetch('DEMO_ADMIN_PASSWORD')

ApplicationRecord.transaction do
  demo_user = User.find_or_initialize_by(email: 'portfolio-demo-user@example.com')
  demo_user.assign_attributes(
    user_name: 'Portfolio Demo User',
    telephone: '09012345678',
    admin: false,
    discarded_at: nil,
    confirmed_at: Time.current,
    password: demo_user_password,
    password_confirmation: demo_user_password
  )
  demo_user.save!

  demo_admin = User.find_or_initialize_by(email: 'portfolio-demo-admin@example.com')
  demo_admin.assign_attributes(
    user_name: 'Portfolio Demo Admin',
    telephone: '09087654321',
    admin: true,
    discarded_at: nil,
    confirmed_at: Time.current,
    password: demo_admin_password,
    password_confirmation: demo_admin_password
  )
  demo_admin.save!

  vehicle = Vehicle.find_or_create_by!(
    vehicle_name: 'Portfolio Demo Car',
    number: '1001',
    manufacture: 'Toyota'
  )

  [demo_user, demo_admin].each do |user|
    next if user.daily_logs.exists?

    user.daily_logs.create!(
      vehicle:,
      departure_datetime: 1.day.ago.change(hour: 8),
      arrival_datetime: 1.day.ago.change(hour: 17),
      departure_distance: 12_340,
      arrival_distance: 12_410,
      departure_location: '東京駅',
      arrival_location: '横浜駅',
      note: 'Portfolio demo log',
      is_alcohol_check: true
    )
  end
end

puts 'Demo data ready: portfolio-demo-user@example.com and portfolio-demo-admin@example.com'
