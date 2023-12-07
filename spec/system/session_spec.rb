# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ログインとログアウト', type: :system do
  before do
    @user = create :user
    visit new_user_session_path
  end

  it 'ログインを行う' do
    fill_in 'メールアドレス', with: @user.email
    fill_in 'パスワード', with: @user.password
    check 'remember_me'
    has_checked_field?('remember_me')
    expect(page).to have_field 'メールアドレス', with: @user.email
    expect(page).to have_field 'パスワード', with: @user.password
    click_on 'ログイン'
    expect(page).to have_current_path(daily_logs_path)
    expect(User.find(@user.id).remember_created_at).not_to eq ''
    # ブラウザを再起動してログインが必要か確認する。
    find_by_id('account').click
    click_link 'Log out'
    expect(current_path).to eq root_path
    page.has_link? 'ログイン'
  end

  context '未認証ユーザーでログインできない。' do
    it '入力内容に不備がある。' do
      fill_in 'メールアドレス', with: Faker::Internet.email
      fill_in 'パスワード', with: 'hogehoge'
      click_on 'ログイン'

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'メールアドレス もしくはパスワードが不正です。'
    end
  end

  context 'パスワードを間違えてログインできない。' do
    it '入力内容に不備がある。' do
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: '123456'
      click_on 'ログイン'

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'メールアドレス もしくはパスワードが不正です。'
    end
  end
end
