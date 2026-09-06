# frozen_string_literal: true

%w[macos-webkit ios-safari].each_with_index do |project, index|
  email = "playwright-#{project}@example.test"
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    user_name: "Playwright #{project}",
    telephone: "0901234567#{index}",
    admin: false,
    confirmed_at: Time.current
  )
  user.password = 'playwright-password'
  user.password_confirmation = 'playwright-password'
  user.save!
  user.daily_logs.delete_all

  vehicle = Vehicle.find_or_initialize_by(
    vehicle_name: "PW#{index + 1}",
    number: "90#{index + 1}",
    manufacture: 'Playwright'
  )
  vehicle.current_drive_distance = 1000
  vehicle.save!

  FavoriteVehicle.find_or_create_by!(user: user, vehicle: vehicle)
end
