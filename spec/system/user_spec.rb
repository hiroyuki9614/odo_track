# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'アプリ全体の動作チェック', type: :system do
  before do
    ActionMailer::Base.deliveries.clear
    @user = create(:user)
    visit new_user_registration_path
  end
  let(:email) { Faker::Internet.unique.email } # ランダムなアドレスを取得するため再定義

  # サインアップの流れ
  # 各項目に情報を記入
  # ↓
  # バリデーションに引っかからなければ確認画面に移行。
  # 確認画面でミスが分かればBACKボタンを押す。
  # 問題が無ければOKボタンを押す。
  # ↓
  # user_index画面に移行。(！！！！暫定！！！！)
  # ↓
  # アカウントのトグルボタンを探してログアウトをクリックする。
  # ↓
  # ログアウトしてトップページへ移行する。
  it 'サインアップを行う' do
    fill_in_user_forms
    fill_in 'お名前(フルネーム)', with: @user.user_name
    click_on 'サインアップ'
    expect(page).to have_content '本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。'
    expect(current_path).to eq root_path
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(page).to have_content '本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。'
    expect(last_email.to).to include email

    ctoken = last_email.body.match(/confirmation_token=([^"]+)/)
    visit "/auth/verification?#{ctoken}"
    # <a href="http://localhost:3000confirmation_token=KEW9Cz3FctJ1-9kb6y"
    expect(current_path).to eq new_user_session_path
    # expect(page).to have_content '1 件のエラーが発生したため user は保存されませんでした:'
    expect(page).to have_content 'アカウントを登録しました。'
    # expect(confirmed_at).not_to be_nil
    fill_in 'メールアドレス', with: email
    fill_in 'パスワード', with: @user.password
    click_on 'ログイン'
    expect(current_path).to eq daily_logs_path
    expect(page).to have_content 'ログインしました。'
  end

  context '入力に不備があり、サインアップできない。' do
    it '入力内容に不備がある。' do
      fill_in 'お名前(フルネーム)', with: ''
      fill_in_user_forms

      click_on 'サインアップ'

      expect(current_path).to eq user_registration_path
      expect(page).to have_content 'お名前を入力してください'
    end
  end

  context 'サインアップでパスワードを空欄にする。' do
    it '入力内容に不備がある。' do
      fill_in 'お名前(フルネーム)', with: @user.user_name
      fill_in 'メールアドレス', with: @user.email
      fill_in '電話番号', with: @user.telephone
      fill_in 'パスワード', with: ''
      fill_in 'パスワード(確認)', with: ''

      click_on 'サインアップ'

      expect(current_path).to eq user_registration_path
      expect(page).to have_content 'パスワードを入力してください'
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end
end
