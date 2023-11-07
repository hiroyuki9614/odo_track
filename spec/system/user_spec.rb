# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'サインアップとログアウト', type: :system do
  let(:user_name) { Faker::Name.unique.name }
  let(:email) { Faker::Internet.email }
  let(:telephone) { '09000001111' }
  let(:password) { Faker::Internet.password(min_length: 6) }
  let(:password_confirmation) { password }

  before do
    visit signup_path
  end

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
    fill_in 'お名前(フルネーム)', with: user_name

    click_on '確認画面へ'
    expect(current_path).to eq confirm_users_path

    click_on 'OK'
    # 登録完了
    expect(current_path).to eq users_path
    check_user_last_data
    # ログイン時にremember_digestに値が記録されない。
    user = User.last
    expect(user.remember_digest).to eq ''

    find_by_id('account').click
    click_link 'Log out'
    expect(current_path).to eq pages_top_path
    page.has_link? 'ログイン'
  end

  context '入力に不備があり、サインアップできない。' do
    it '入力内容に不備がある。' do
      fill_in 'お名前(フルネーム)', with: ''
      fill_in_user_forms

      click_on '確認画面へ'

      expect(current_path).to eq confirm_users_path
      expect(page).to have_content 'お名前を入力してください'
    end
  end
  context '完了画面で戻るを押した場合' do
    it 'ユーザーを登録できる' do
      fill_in_user_forms
      fill_in 'お名前(フルネーム)', with: user_name
      click_on '確認画面へ'
      expect(current_path).to eq confirm_users_path
      expect(current_path).to eq confirm_users_path
      click_on 'BACK'
      expected_form_value_for_signup
      click_on '確認画面へ'
      expect(current_path).to eq confirm_users_path

      # 確認ページを再読込してもデータが保持されている。
      visit confirm_users_path
      click_on 'BACK'
      expect(current_path).to eq users_path
      expected_form_value_for_signup
      click_on '確認画面へ'
      expect(current_path).to eq confirm_users_path
      click_on 'OK'
      expect(current_path).to eq users_path
      expect(page).to have_text 'ユーザー登録が完了しました！'
      check_user_last_data
    end
  end
end
