# frozen_string_literal: true

class CreateDailyLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_logs do |t|
      t.datetime :departure_datetime, null: false, comment: '乗車日時'
      t.datetime :arrival_datetime, null: false, comment: '到着日時'
      t.integer :departure_distance, null: false, comment: '出発時の距離'
      t.integer :arrival_distance, null: false, comment: '到着時の距離'
      t.string :departure_location, null: false, comment: '出発場所'
      t.string :arrival_location, null: false, comment: '到着場所'
      t.text :note, null: false, default: '', comment: '備考'

      t.timestamps
    end
  end
end
