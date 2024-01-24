# frozen_string_literal: true

class Vehicle < ApplicationRecord
  include Discard::Model
  has_many :favorite_vehicles
  has_many :daily_log

  validates :vehicle_name, presence: true, length: { maximum: 20 }
  validates :number, presence: true, length: { maximum: 5 }, numericality: { only_integer: true }
  validates :manufacture, presence: true, length: { maximum: 20 }
  validates :current_drive_distance, length: { maximum: 10 }, numericality: { only_integer: true }, allow_blank: true
  validates :discarded_at, presence: true, allow_blank: true

  after_initialize :format_number
  after_initialize :format_current_drive_distance
  after_initialize :format_nil_current_drive_distance

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

  def format_current_drive_distance
    return if current_drive_distance.blank?

    self.current_drive_distance = current_drive_distance.to_s.gsub(',', '')
  end

  def format_nil_current_drive_distance
    return if current_drive_distance.present?

    self.current_drive_distance ||= ''
  end
end
