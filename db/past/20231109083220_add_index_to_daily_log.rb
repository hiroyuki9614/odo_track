class AddIndexToDailyLog < ActiveRecord::Migration[7.1]
  def change
    add_index :daily_logs, %i[user_id created_at]
  end
end
