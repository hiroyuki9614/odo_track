# frozen_string_literal: true

# DailyLogモデルにカラムを追加する。
class AddOptionsToDailyLog < ActiveRecord::Migration[7.1]
  def change
    add_column :daily_logs, :is_alcohol_check, :boolean, null: false, default: false, comment: 'アルコールチェック'
    add_column :daily_logs, :is_studless_tire, :boolean, null: false, default: false, comment: 'スタッドレスタイヤの装着'
    add_column :daily_logs, :approval_status, :integer, null: false,  default: 0, comment: '承認の有無'
  end
end
