# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  # Vehicleテーブルのテストデータ
  describe '#valid?' do
    let(:vehicle_name) { 'ハイエース' } # 車両名称
    let(:number) { '1' } # ナンバー
    let(:manufacture) { 'トヨタ' } # メーカー
    let(:current_drive_distance) { '123' } # 現在の走行距離
    let(:params) do
      {
        vehicle_name:,
        number:,
        manufacture:,
        current_drive_distance:
      }
    end

    it '返り値はtrueになること' do
      vehicle = Vehicle.new(params)
      expect(vehicle.valid?).to eq(true),
                                "Expected Vehicle to be valid, but got errors: #{vehicle.errors.full_messages.to_sentence}"
    end

    subject { Vehicle.new(params).valid? }

    it { is_expected.to eq true }

    # paramsの部分的なバリデーションチェック
    context '車両名称が空白' do
      let(:vehicle_name) { '' }

      it { is_expected.to eq false }
    end

    context '車両名称が20文字以下' do
      let(:vehicle_name) { 'あ' * 20 }
      it { is_expected.to eq true }
    end

    context '車両名称が20文字以上' do
      let(:vehicle_name) { 'あ' * 21 }
      it { is_expected.to eq false }
    end

    context 'ナンバーが空白' do
      let(:number) { '' }

      it { is_expected.to eq false }
    end

    context 'ナンバーが5文字以下' do
      let(:number) { '12345' }
      it { is_expected.to eq true }
    end

    context 'ナンバーが5文字以上' do
      let(:number) { '123456' }
      it { is_expected.to eq false }
    end

    context 'ナンバーのフォーマットチェック' do
      let(:number) { '12-34' }
      it { is_expected.to eq true }
    end

    context 'ナンバーが全角' do
      let(:number) { '１２３４' }
      it { is_expected.to eq true }
    end

    context '現在の走行距離が空白' do
      let(:current_drive_distance) { '' }

      it { is_expected.to eq true }
    end

    context '現在の走行距離が10文字以下' do
      let(:current_drive_distance) { '1' * 10 }
      it { is_expected.to eq true }
    end

    context '現在の走行距離が10文字以上' do
      let(:current_drive_distance) { '1' * 11 }
      it { is_expected.to eq false }
    end

    context '現在の走行距離のフォーマットチェック' do
      let(:current_drive_distance) { '1,234' }
      it { is_expected.to eq true }
    end
  end
end
