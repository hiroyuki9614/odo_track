# frozen_string_literal: true

# 運転日報テーブルについてのモデル 到着・出発時の距離や場所などを記録する。
class DailyLog < ApplicationRecord
  include Discard::Model
  belongs_to :user
  belongs_to :vehicle
  has_one :favorite_vehicle, through: :user
  # belongs_to :frequent_destination

  # enum approval_status: { incomplete: 0, approved: 1, unapproved: 2 }

  validates :departure_datetime, presence: true
  validates :arrival_datetime, presence: true
  validates :departure_distance, presence: true, length: { maximum: 10 }
  validates :arrival_distance, presence: true, length: { maximum: 10 }
  validates :departure_location, presence: true, length: { maximum: 100 }
  validates :arrival_location, presence: true, length: { maximum: 100 }
  validates :note, length: { maximum: 1000 }
  validates :is_alcohol_check, acceptance: { message: 'を実施してください。' }
  # validates :user_id, presence: true, blank: true
  validates :vehicle_id, presence: true

  validate :arrival_time_after_departure_time
  validate :arrival_distance_after_departure_distance

  after_save :update_vehicle_distance, if: :saved_change_to_arrival_distance?
  after_discard :update_vehicle_distance if respond_to?(:after_discard)

  private

  def arrival_time_after_departure_time
    return unless departure_datetime.presence && arrival_datetime.presence
    return unless arrival_datetime <= departure_datetime

    errors.add(:departure_datetime, 'が到着時間を超えています。')
  end

  def arrival_distance_after_departure_distance
    return unless departure_distance.present? && arrival_distance.present?
    return unless arrival_distance <= departure_distance

    errors.add(:departure_distance, 'が到着時の走行距離を超えています。')
  end

  def update_vehicle_distance
    # 関連付けられた車両のIDに対応する日報を検索し、arrival_distanceの最大値を取得
    max_distance = DailyLog.where(vehicle_id:).maximum(:arrival_distance)

    # max_distanceがnil（日報がない）場合は、current_drive_distanceを0にリセット
    max_distance ||= 0

    # 車両のcurrent_drive_distanceを更新
    vehicle.update(current_drive_distance: max_distance)
  end

  def approval_status_i18n
    I18n.t("enum.daily_log.approval_status.#{approval_status}")
  end

  # ransackが使用できるパラメーター
  def self.ransackable_attributes(_auth_object = nil)
    %w[approval_status arrival_datetime arrival_distance arrival_location
       created_at departure_datetime departure_distance departure_location
       discarded_at id id_value is_alcohol_check is_studless_tire note
       updated_at user_id]
  end
end
