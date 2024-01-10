class AddColumnDiscardedAtToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :discarded_at, :datetime, default: '', comment: '論理削除'
  end
end
