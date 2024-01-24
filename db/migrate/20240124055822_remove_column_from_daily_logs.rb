class RemoveColumnFromDailyLogs < ActiveRecord::Migration[7.1]
  def change
    remove_column :daily_logs, :is_studless_tire, :boolean
    remove_column :daily_logs, :approval_status, :integer
  end
end
