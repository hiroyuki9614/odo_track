# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '注文フォーム', type: :system do
  before do
    @user = create :user
    sign_in @user
    visit new_daily_log_path
  end

  let(:departure_datetime) { Time.zone.today } # 出発日時
  let(:arrival_datetime) { Time.now } # 到着日時
  let(:departure_distance) { 123 } # 出発時の距離
  let(:arrival_distance) { 456 } # 到着時の距離
  let(:departure_location) { '本社' } # 出発場所
  let(:arrival_location) { '名古屋ドーム' } # 到着場所
  let(:note) { '得意先名：ドラゴン商事 件名：照明の交換' } # 備考欄

  # 運転日報の登録の操作の流れ
  # 各項目に情報を記入
  # ↓
  # バリデーションに引っかからなければ確認画面に移行。
  # 確認画面でミスが分かればBACKボタンを押す。
  # 問題が無ければOKボタンを押す。
  # ↓
  # index画面に移行。

  it '運転日報を登録する事' do
    expect(current_path).to eq new_daily_log_path
    fill_in_daily_log_forms

    click_on '確認画面へ'
    expect(current_path).to eq confirm_daily_logs_path
    click_on 'OK'
    expect(current_path).to eq daily_logs_path

    check_daily_log_last_data
    # 削除機能のチェック
    click_link 'destroy'
    expect(page).to have_content '運転日報はありません。'
    # <a data-turbo-method="delete" data-turbo-confirm="Are you sure?" href="/daily_logs/1">destroy</a>
  end

  context '入力情報に不備がある場合' do
    it '確認画面へ遷移することができない' do
      fill_in_daily_log_forms
      fill_in '到着場所', with: ''
      click_on '確認'

      expect(current_path).to eq confirm_daily_logs_path
      expect(page).to have_content '到着場所を入力してください'
    end
  end

  context '完了画面で戻るを押した場合' do
    it '運転日報を登録できる' do
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
      # show画面からも削除できる
      click_link 'show'
      daily_log = DailyLog.last
      expect(current_path).to eq daily_logs_show_path(id: daily_log.id)
      click_link 'destroy'
      expect(page).to have_content '運転日報はありません。'
    end
  end
  context 'idをcurrent_user以外のidにして登録しようとする。' do
    it '確認画面に移行できない。' do
      fill_in_daily_log_forms
      find(:xpath, '//*[@id="daily_log_user_id"]', visible: false).set '1'
      click_on '確認'
      expect(current_path).to eq confirm_daily_logs_path
      expect(page).to have_content '不正な操作が行われました。'
    end
    it '確認画面でデータを登録できない。' do
      fill_in_daily_log_forms
      click_on '確認'
      expect(current_path).to eq confirm_daily_logs_path
      find(:xpath, '//*[@id="daily_log_user_id"]', visible: false).set '1'
      click_on 'OK'
      expect(current_path).to eq daily_logs_path
      expect(page).to have_content '不正な操作が行われました。'
      daily_log = DailyLog.last
      expect(daily_log.user_id).not_to eq @user.id
      expect(daily_log.departure_datetime.strftime('%Y年%m月%d日 %H:%M')).not_to eq departure_datetime.strftime('%Y年%m月%d日 %H:%M')
      expect(daily_log.arrival_datetime.strftime('%Y年%m月%d日 %H:%M')).not_to eq arrival_datetime.strftime('%Y年%m月%d日 %H:%M')
      expect(daily_log.departure_distance).not_to eq departure_distance
      expect(daily_log.arrival_distance).not_to eq arrival_distance
      expect(daily_log.departure_location).not_to eq departure_location
      expect(daily_log.arrival_location).not_to eq arrival_location
      expect(daily_log.note).not_to eq note
    end
  end
end
