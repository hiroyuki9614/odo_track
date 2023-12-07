# frozen_string_literal: true

require 'faker'
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
ApplicationRecord.transaction do
  DailyLog.delete_all
  User.delete_all
  Vehicle.delete_all

  5.times do |_n|
    Vehicle.create!(
      vehicle_name: Faker::Vehicle.model,
      number: rand(0...9999),
      manufacture: Faker::Vehicle.manufacture,
      current_drive_distance: rand(0...10_000)
    )
  end

  User.create!(
    user_name: 'テストくん1',
    email: 'mmm@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストくん2',
    email: 'aaa@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストくん3',
    email: 'fff@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストくん4',
    email: 'ttt@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: '管理者くん',
    email: 'ggg@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: true,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: '退職くん',
    email: 'eee@example.com',
    telephone: '876123',
    password: 'aaaaaa', # 正しいフィールドを使用する
    password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: DateTime.now,
    admin: true,
    confirmed_at: DateTime.now
  )
end

users = User.order(:created_at).take(3)
vehicles = Vehicle.order(:created_at).take(3)
3.times do |_n|
  users.each do |user|
    vehicles.each do |vehicle|
      DailyLog.create!(
        user_id: user.id,
        vehicle_id: vehicle.id,
        departure_datetime: Faker::Time.between(from: DateTime.now - 3, to: DateTime.now - 2),
        arrival_datetime: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now),
        departure_distance: rand(1...100),
        arrival_distance: rand(100...200),
        departure_location: Faker::Address.city,
        arrival_location: Faker::Address.city,
        note: Faker::Config.random.seed,
        is_alcohol_check: true,
        is_studless_tire: false,
        approval_status: 0
      )
    end
  end
end
#   User.create(id: 4, user_name: '管理者くん', email: 'ccc@example.com', telephone: '989true23', password: 'aaaaaa',
#               password_confirmation: 'aaaaaa', discarded_at: true, admin: true)
#   User.create(id: 5, user_name: '退職くん', email: 'ddd@example.com', telephone: '090true23', password: 'aaaaaa',
#               password_confirmation: 'aaaaaa', discarded_at: false, admin: false)
# end.strftime('%Y-%m-%d %H:%M')
