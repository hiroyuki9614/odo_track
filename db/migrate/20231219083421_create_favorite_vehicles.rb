class CreateFavoriteVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_vehicles do |t|
      t.references :user, foreign_key: { on_delete: :restrict }, null: false
      t.references :vehicle, foreign_key: { on_delete: :restrict }, null: false
      t.text :favorite_vihicle_note, default: '', null: false

      t.timestamps
    end
  end
end
