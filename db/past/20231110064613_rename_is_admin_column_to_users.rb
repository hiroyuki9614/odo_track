class RenameIsAdminColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :is_admin, :admin
  end
end
