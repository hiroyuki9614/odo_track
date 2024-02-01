# frozen_string_literal: true

require 'faker'
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
    user_name: 'テストユーザー1',
    email: 'user1@example.com',
    telephone: '03000000000',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストユーザー2',
    email: 'user2@example.com',
    telephone: '04000000000',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストユーザー3',
    email: 'user3@example.com',
    telephone: '02000000000',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: 'テストユーザー4',
    email: 'user4@example.com',
    telephone: '11100000000',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: false,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: '管理者ユーザー',
    email: 'admin@example.com',
    telephone: '02000000000',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
    discarded_at: '',
    admin: true,
    confirmed_at: DateTime.now
  )
  User.create!(
    user_name: '退職ユーザー',
    email: 'eee@example.com',
    telephone: '02000000001',
    password: 'password', # 正しいフィールドを使用する
    # password_confirmation: 'aaaaaa', # 正しいフィールドを使用する
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
        # frequent_destination: '',
        departure_datetime: Faker::Time.between(from: DateTime.now - 3, to: DateTime.now - 2),
        arrival_datetime: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now),
        departure_distance: rand(1...100),
        arrival_distance: rand(100...200),
        departure_location: Faker::Address.city,
        arrival_location: Faker::Address.city,
        note: Faker::Config.random.seed,
        is_alcohol_check: true
      )
    end
  end
end
