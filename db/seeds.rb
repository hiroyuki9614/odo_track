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

  User.create!(id: 1, user_name: 'テストくん1', email: 'mmm@example.com', telephone: '876123', password: 'aaaaaa',
               password_confirmation: 'aaaaaa', is_active: true, is_admin: false)
  User.create(id: 2, user_name: 'テストくん2', email: 'aaa@example.com', telephone: '654true23', password: 'aaaaaa',
              password_confirmation: 'aaaaaa', is_active: true, is_admin: false)
  User.create(id: 3, user_name: 'テストくん3', email: 'bbb@example.com', telephone: '899true23', password: 'aaaaaa',
              password_confirmation: 'aaaaaa', is_active: true, is_admin: false)
  User.create(id: 4, user_name: '管理者くん', email: 'ccc@example.com', telephone: '989true23', password: 'aaaaaa',
              password_confirmation: 'aaaaaa', is_active: true, is_admin: true)
  User.create!(id: 5, user_name: '退職くん', email: 'ddd@example.com', telephone: '090true23', password: 'aaaaaa',
               password_confirmation: 'aaaaaa', is_active: false, is_admin: false)
end

#   3.times do |_n|
#     User.create!(
#       user_name: Faker::Name.unique.name,
#       email: Faker::Internet.email,
#       telephone: Faker::PhoneNumber.cell_phone,
#       password: 'aaaaaa',
#       password_confirmation: 'aaaaaa',
#       is_active: true,
#       is_admin: false
#     )
#   end
#   User.create(id: 4, user_name: '管理者くん', email: 'ccc@example.com', telephone: '989true23', password: 'aaaaaa',
#               password_confirmation: 'aaaaaa', is_active: true, is_admin: true)
#   User.create(id: 5, user_name: '退職くん', email: 'ddd@example.com', telephone: '090true23', password: 'aaaaaa',
#               password_confirmation: 'aaaaaa', is_active: false, is_admin: false)
# end
