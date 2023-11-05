# frozen_string_literal: true

# daily_logのシステム用ヘルパーメソッド
module DailyLogHelpers
  def fill_in_daily_log_forms
    # select 'テストくん1', from: 'ユーザー名' テストのため省略
    fill_in '出発日時', with: departure_datetime
    fill_in '到着日時', with: arrival_datetime
    fill_in '出発時の距離', with: departure_distance
    fill_in '到着時の距離', with: arrival_distance
    fill_in '出発場所', with: departure_location
    fill_in '到着場所', with: arrival_location
    fill_in 'メモ（件名,客先等)', with: note
    # check 'スタッドレスタイヤの装着'
    check 'アルコール検査は実施しましたか？'
  end

  def check_daily_log_last_data
    daily_log = DailyLog.last
    expect(daily_log.user_id).to eq 1
    expect(daily_log.departure_datetime.strftime('%Y年%m月%d日 %H:%M')).to eq departure_datetime.strftime('%Y年%m月%d日 %H:%M')
    expect(daily_log.arrival_datetime.strftime('%Y年%m月%d日 %H:%M')).to eq arrival_datetime.strftime('%Y年%m月%d日 %H:%M')
    expect(daily_log.departure_distance).to eq departure_distance
    expect(daily_log.arrival_distance).to eq arrival_distance
    expect(daily_log.departure_location).to eq departure_location
    expect(daily_log.arrival_location).to eq arrival_location
    expect(daily_log.note).to eq note
    expect(daily_log.is_studless_tire).to eq false
    expect(daily_log.is_alcohol_check).to eq true
  end

  def expected_form_value_for_daily_log
    expect(current_path).to eq daily_logs_path
    expect(page).to have_select 'ユーザー名', selected: 'テストくん1'
    expect(page).to have_field '出発日時', with: departure_datetime.strftime('%Y-%m-%dT%H:%M:%S')
    expect(page).to have_field '到着日時', with: arrival_datetime.strftime('%Y-%m-%dT%H:%M:%S')
    expect(page).to have_field '出発時の距離', with: departure_distance
    expect(page).to have_field '到着時の距離', with: arrival_distance
    expect(page).to have_field '出発場所', with: departure_location
    expect(page).to have_field '到着場所', with: arrival_location
    expect(page).to have_field 'メモ（件名,客先等)', with: note
    expect(page).to have_unchecked_field 'スタッドレスタイヤの装着'
    expect(page).to have_checked_field   'アルコール検査は実施しましたか？'
  end
end
