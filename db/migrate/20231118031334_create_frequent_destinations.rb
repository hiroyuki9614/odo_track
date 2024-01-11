class CreateFrequentDestinations < ActiveRecord::Migration[7.1]
  def change
    create_table :frequent_destinations do |t|
      t.string :destination_name, null: false, comment: '目的地'
      t.text :destination_note, null: false, comment: '目的地についてのメモ'

      t.references :daily_log, foreign_key: { on_update: :restrict, on_delete: :restrict }, comment: '運転日報参照'
      # t.references :user_id, foreign_key: { on_update: :restrict, on_delete: :restrict }, comment: 'ユーザー参照'
      t.timestamps
    end
  end
end
