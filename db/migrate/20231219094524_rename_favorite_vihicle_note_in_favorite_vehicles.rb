class RenameFavoriteVihicleNoteInFavoriteVehicles < ActiveRecord::Migration[7.1]
  def change
    rename_column :favorite_vehicles, :favorite_vihicle_note, :favorite_vehicle_note
  end
end
