# frozen_string_literal: true

# 運転日報テーブルについてのモデル 到着・出発時の距離や場所などを記録する。
class DailyLog < ApplicationRecord
  belongs_to :user

  enum approval_status: { incomplete: 0, approved: 1, unapproved: 2 }

  validates :departure_datetime, presence: true
  validates :arrival_datetime, presence: true
  validates :departure_distance, presence: true, length: { maximum: 10 }
  validates :arrival_distance, presence: true, length: { maximum: 10 }
  validates :departure_location, presence: true, length: { maximum: 100 }
  validates :arrival_location, presence: true, length: { maximum: 100 }
  validates :note, length: { maximum: 1000 }
  validates :is_alcohol_check, acceptance: { message: 'を実施してください。' }
  validates :user_id, presence: true

  validate :arrival_time_after_departure_time
  validate :arrival_distance_after_departure_distance

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

  # 後ほど、車両の最後の走行距離と出発時の距離のバリデーションを追加する。

  def approval_status_i18n
    I18n.t("enum.daily_log.approval_status.#{approval_status}")
  end
end
