FactoryBot.define do
  factory :user do
    user_name { 'テスト太郎' } # 氏名
    email { 'mmnnoov@gmail.com' } # メールアドレス
    telephone { '09051691918' } # 電話番号
    password { 'aaaaaa' } # パスワード
    password_confirmation { 'aaaaaa' } # パスワード(確認)
    is_active { true } # ユーザーの在籍
    is_admin { false } # 管理者権限
  end
end
