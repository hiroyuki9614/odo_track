# frozen_string_literal: true

class FavoriteVehicle < ApplicationRecord
  belongs_to :vehicle
  belongs_to :user

  validate :unique_vehicle_for_user

  def unique_vehicle_for_user
    # 同じユーザーが同じ車両をすでに登録しているか確認
    existing_favorite = FavoriteVehicle.find_by(user_id:, vehicle_id:)
    return unless existing_favorite && existing_favorite.id != id

    errors.add(:vehicle_id, 'は既にお気に入りに登録されています。')
  end
end
