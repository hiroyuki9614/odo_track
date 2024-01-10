class RenameIsActiveColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :is_active, null: false, default: true, comment: '社員の在籍状況'
    add_column :users, :discarded_at, :datetime, default: '', comment: '論理削除'
    add_column :daily_logs, :discarded_at, :datetime, default: '', comment: '論理削除'
    add_index :users, :discarded_at
  end
end
