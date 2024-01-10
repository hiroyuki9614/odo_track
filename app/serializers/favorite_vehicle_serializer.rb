# app/serializers/favorite_vehicle_serializer.rb

class FavoriteVehicleSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :vehicle_id, :favorite_vehicle_note, :vehicle_name, :vehicle_number

  def vehicle_name
    object.vehicle.vehicle_name
  end

  def vehicle_number
    object.vehicle.number
  end
end
