# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    vehicle_name { Faker::Vehicle.model.first(20) } # 氏名
    number { rand(0...9999) } # メールアドレス
    manufacture { Faker::Vehicle.manufacture.first(20) } # 電話番号
    current_drive_distance { rand(0...10_000) } # パスワード
  end
end
