# frozen_string_literal: true

class VehicleSerializer < ActiveModel::Serializer
  include ActiveSupport::NumberHelper
  attributes :id, :vehicle_name, :number, :manufacture, :current_drive_distance, :created_at, :discarded_at,
             :vehicle_name_and_number

  def created_at
    object.created_at.strftime('%Y/%m/%d %H:%M')
  end

  def current_drive_distance
    number_to_delimited(object.current_drive_distance)
  end

  def vehicle_name_and_number
    "#{object.vehicle_name} - #{object.number}"
  end
end
