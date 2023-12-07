# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.string :vehicle_name, null: false, comment: '車両名'
      t.string :number, null: false, comment: 'ナンバー'
      t.string :manufacture, null: false, comment: 'メーカー名'
      t.integer :current_drive_distance, null: false, default: 0, comment: '現在の走行距離'

      # 以下の行は`t.references` を使用して、外部キーを追加します
      t.references :daily_log, foreign_key: { on_update: :restrict, on_delete: :restrict }, comment: '運転日報参照'
      t.timestamps
    end

    # インデックスを追加する際には、カラム名を正確に指定する必要があります
    # `vehicle_number` は存在しないため `vehicle_name` に変更します
    add_index :vehicles, %i[vehicle_name number manufacture], unique: true
  end
end
