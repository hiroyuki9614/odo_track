# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'サインアップとログイン', type: :system do
  let(:user_name) { 'テス太郎' } # ユーザー名
  let(:email) { 'mmm@gmail.com' } # メールアドレス
  let(:telephone) { '0120117117' } # 電話番号
  let(:password) { 'aaaaaa' } # パスワード
  let(:password_confirmation) { 'aaaaaa' } # パスワード(確認用)

  # サインアップの流れ
  # 各項目に情報を記入
  # ↓
  # バリデーションに引っかからなければ確認画面に移行。
  # 確認画面でミスが分かればBACKボタンを押す。
  # 問題が無ければOKボタンを押す。
  # ↓
  # user_index画面に移行。(！！！！暫定！！！！)

  it 'サインアップを行う' do
    visit signup_path
    expect(current_path).to eq signup_path

    fill_in_user_forms
    fill_in 'お名前(フルネーム)', with: user_name

    click_on '確認画面へ'
    expect(current_path).to eq confirm_users_path

    click_on 'OK'
    # 登録完了
    expect(current_path).to eq users_path

    check_user_last_data

    find_by_id('account').click
    expect(page).to have_link 'Log out'
    expect(current_path).to eq pages_top_path
  end
end
