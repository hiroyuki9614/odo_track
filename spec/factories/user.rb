# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    user_name { Faker::Name.unique.name } # 氏名
    email { Faker::Internet.unique.email } # メールアドレス
    telephone { '09051691918' } # 電話番号
    password { Faker::Internet.password(min_length: 6) } # パスワード
    password_confirmation { password } # パスワード(確認)
    admin { false } # 管理者権限
    confirmed_at { Date.today } # deviseのテストに通るようにする。
  end
end
