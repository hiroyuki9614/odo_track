# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '注文フォーム', type: :system do
  let(:departure_datetime) { Time.zone.today } # 出発日時
  let(:arrival_datetime) { Time.now } # 到着日時
  let(:departure_distance) { 123 } # 出発時の距離
  let(:arrival_distance) { 456 } # 到着時の距離
  let(:departure_location) { '本社' } # 出発場所
  let(:arrival_location) { '名古屋ドーム' } # 到着場所
  let(:note) { '得意先名：ドラゴン商事 件名：照明の交換' } # 備考欄
  let(:is_studless_tire) { false } # スタッドレスタイヤの装着
  let(:is_alcohol_check) { true } # アルコール検査の実施

  # 運転日報の登録の操作の流れ
  # 各項目に情報を記入
  # ↓
  # バリデーションに引っかからなければ確認画面に移行。
  # 確認画面でミスが分かればBACKボタンを押す。
  # 問題が無ければOKボタンを押す。
  # ↓
  # index画面に移行。

  it '運転日報を登録する事' do
    visit new_daily_log_path
    fill_in_daily_log_forms
    select 'テストくん1', from: 'ユーザー名'

    click_on '確認画面へ'
    expect(current_path).to eq confirm_daily_logs_path
    click_on 'OK'
    expect(current_path).to eq daily_logs_path

    check_daily_log_last_data
  end

  context '入力情報に不備がある場合' do
    it '確認画面へ遷移することができない' do
      visit new_daily_log_path

      select '', from: 'ユーザー名'
      fill_in_daily_log_forms

      click_on '確認'

      expect(current_path).to eq confirm_daily_logs_path
      expect(page).to have_content 'ユーザー名を入力してください'
    end
  end

  context '完了画面で戻るを押した場合' do
    it '運転日報を登録できる' do
      visit new_daily_log_path

      select 'テストくん1', from: 'ユーザー名'
      fill_in_daily_log_forms

      click_on '確認'
      expect(current_path).to eq confirm_daily_logs_path
      click_on 'BACK'
      expected_form_value_for_daily_log
      click_on '確認'
      expect(current_path).to eq confirm_daily_logs_path

      # 確認ページを再読込してもデータが保持されている。
      visit confirm_daily_logs_path
      click_on 'BACK'
      expected_form_value_for_daily_log
      click_on '確認'
      expect(current_path).to eq confirm_daily_logs_path
      click_on 'OK'
      expect(current_path).to eq daily_logs_path

      check_daily_log_last_data
    end
  end
end
