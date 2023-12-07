# frozen_string_literal: true

class Vehicle < ApplicationRecord
  include Discard::Model

  validates :vehicle_name, presence: true, length: { maximum: 20 }
  validates :number, presence: true, length: { maximum: 5 }, numericality: { only_integer: true }
  validates :manufacture, presence: true, length: { maximum: 20 }
  validates :current_drive_distance, presence: true, numericality: { only_integer: true }
  validates :discarded_at, presence: true, allow_blank: true

  after_initialize :format_number

  # ransackで取得を許可するテーブル
  def self.ransackable_attributes(_auth_object = nil)
    %w[vehicle_name number manufacturer current_drive_distance]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[vehicle_name number manufacturer current_drive_distance]
  end

  def self.selectable_vehicles
    Vehicle.all.map do |vehicle|
      ["#{vehicle.vehicle_name} - #{vehicle.number}", vehicle.id]
    end
  end

  private

  def format_number
    return if number.blank?

    self.number = number.tr('０-９', '0-9').delete('^0-9')
  end
end
