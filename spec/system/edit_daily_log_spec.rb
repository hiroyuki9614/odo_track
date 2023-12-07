# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '注文フォーム', type: :system do
  before do
    @user = create :user
    sign_in @user
    @daily_log = create(:daily_log, user_id: @user.id) # create(:user, user_name: 'hogehoge')
    visit daily_logs_path
  end
  it '運転日報を編集できる' do
    click_link 'edit'
    fill_in_edit_daily_log_forms
    fill_in '到着場所', with: 'テスト'
    click_on '確認画面へ'
    expect(current_path).to eq edit_confirm_daily_log_path(@daily_log)
    click_on 'OK'
    expect(current_path).to eq daily_logs_path

    check_edit_daily_log_last_data
    daily_log = DailyLog.last
    expect(daily_log.arrival_location).to eq 'テスト'
  end

  context '入力情報に不備がある場合' do
    it '確認画面へ遷移することができない' do
      click_link 'edit'
      fill_in '到着場所', with: ''
      click_on '確認'

      expect(current_path).to eq edit_confirm_daily_log_path(@daily_log)
      expect(page).to have_content '到着場所を入力してください'
      has_no_button?('OK')
    end
  end
end
