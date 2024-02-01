class DailyLogSerializer < ActiveModel::Serializer
  include ActiveSupport::NumberHelper
  attributes :id, :departure_datetime, :arrival_datetime, :departure_distance, :arrival_distance,
             :departure_location, :arrival_location, :note, :is_alcohol_check, :vehicle_id, :user_name

  def departure_datetime
    object.departure_datetime.strftime('%Y/%m/%d %H:%M')
  end

  def arrival_datetime
    object.arrival_datetime.strftime('%Y/%m/%d %H:%M')
  end

  def user_name
    object.user.user_name
  end
end
