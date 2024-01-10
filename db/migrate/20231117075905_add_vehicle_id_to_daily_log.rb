class AddVehicleIdToDailyLog < ActiveRecord::Migration[7.1]
  def change
    add_column :daily_logs, :vehicle_id, :integer, null: false, default: '', comment: '車両名'
  end
end
