class DailyLogsSerializer < ActiveModel::Serializer
  include ActiveSupport::NumberHelper
  attributes :id, :departure_datetime, :arrival_datetime, :departure_distance, :arrival_distance,
             :departure_location, :created_at, :arrival_location, :note, :is_alcohol_check,
             :vehicle_id, :vehicle_name, :vehicle_number, :vehicle_current_drive_distance, :user_name

  def created_at
    object.created_at.strftime('%Y/%m/%d %H:%M')
  end

  def departure_datetime
    object.departure_datetime.strftime('%Y/%m/%d %H:%M')
  end

  def arrival_datetime
    object.arrival_datetime.strftime('%Y/%m/%d %H:%M')
  end

  def vehicle_name
    object.vehicle.vehicle_name
  end

  def vehicle_number
    object.vehicle.number
  end

  def vehicle_current_drive_distance
    object.vehicle.current_drive_distance
  end

  def user_name
    object.user.user_name
  end
end
