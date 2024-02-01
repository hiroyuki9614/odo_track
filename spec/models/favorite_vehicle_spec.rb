# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavoriteVehicle, type: :model do
  # FavoriteVehicleテーブルのテストデータ
  describe '#valid?' do
    let(:user) { FactoryBot.create(:user) }
    let(:vehicle) { FactoryBot.create(:vehicle) }
    let(:user_id) { user.id }
    let(:vehicle_id) { vehicle.id }
    let(:favorite_vehicle_note) { 'カラー：黒' } # 車両名称
    let(:params) do
      {
        user_id:,
        vehicle_id:,
        favorite_vehicle_note:
      }
    end

    it '返り値はtrueになること' do
      favorite_vehicle = FavoriteVehicle.new(params)
      expect(favorite_vehicle.valid?).to eq(true),
                                         "Expected FavoriteVehicle to be valid, but got errors: #{favorite_vehicle.errors.full_messages.to_sentence}"
    end

    subject { FavoriteVehicle.new(params).valid? }

    it { is_expected.to eq true }

    # paramsの部分的なバリデーションチェック
    context '車両idが空白' do
      let(:vehicle_id) { '' }

      it { is_expected.to eq false }
    end

    context 'ユーザーidが空白' do
      let(:user_id) { '' }

      it { is_expected.to eq false }
    end

    context '備考が空白' do
      let(:favorite_vehicle_note) { '' }

      it { is_expected.to eq true }
    end

    context '備考が1000文字以内' do
      let(:favorite_vehicle_note) { 'a' * 1000 }

      it { is_expected.to eq true }
    end

    context '備考が1000文字以上' do
      let(:favorite_vehicle_note) { 'a' * 1001 }

      it { is_expected.to eq false }
    end
  end
end
