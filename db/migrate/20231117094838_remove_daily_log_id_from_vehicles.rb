class RemoveDailyLogIdFromVehicles < ActiveRecord::Migration[7.1]
  def change
    remove_column :vehicles, :daily_log_id, :integer
  end
end
