# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyLog, type: :model do
  # テストデータ
  describe '#valid?' do
    let(:user) { FactoryBot.create(:user) }
    let(:user_id) { user.id }
    let(:departure_datetime) { Time.zone.today } # 出発日時
    let(:arrival_datetime) { Time.now } # 到着日時
    let(:departure_distance) { 123 } # 出発時の距離
    let(:arrival_distance) { 456 } # 到着時の距離
    let(:departure_location) { '本社' } # 出発場所
    let(:arrival_location) { '名古屋ドーム' } # 到着場所
    let(:note) { '得意先名：ドラゴン商事 件名：照明の交換' } # 備考欄
    let(:is_studless_tire) { false } # スタッドレスタイヤの装着
    let(:is_alcohol_check) { true } # アルコール検査の実施
    let(:params) do 
      {
        user_id:,
        departure_datetime:,
        arrival_datetime:,
        departure_distance:,
        arrival_distance:,
        departure_location:,
        arrival_location:,
        note:,
        is_alcohol_check:,
        is_studless_tire:
      }
    end

    it '返り値はtrueになること' do
      daily_log = DailyLog.new(params)
      expect(daily_log.valid?).to eq(true),
                                  "バリデーションのエラーメッセージ: #{daily_log.errors.full_messages.to_sentence}"
    end

    subject { DailyLog.new(params).valid? }

    it { is_expected.to eq true }

    # paramsの部分的なバリデーションチェック
    context '名前が選択されていない' do
      let(:user_id) { '' }
      it { is_expected.to eq false }
    end

    context '出発時間が空白' do
      let(:departure_datetime) { '' }

      it { is_expected.to eq false }
    end

    context '到着時間が空白' do
      let(:departure_datetime) { '' }

      it { is_expected.to eq false }
    end

    context '出発時間が到着時間を超えている' do
      let(:departure_datetime) { Time.now }
      let(:arrival_datetime) { Time.zone.today }

      it { is_expected.to eq false }
    end

    context '出発時の距離が空白' do
      let(:departure_distance) { '' }

      it { is_expected.to eq false }
    end

    context '到着時の距離が空白' do
      let(:arrival_location) { '' }

      it { is_expected.to eq false }
    end

    context '出発時の距離が到着時の距離を超えている' do
      let(:departure_distance) { '2' }
      let(:arrival_distance) { '1' }

      it { is_expected.to eq false }
    end
    context '出発場所が空白' do
      let(:departure_location) { '' }

      it { is_expected.to eq false }
    end

    context '到着場所が空白' do
      let(:arrival_location) { '' }

      it { is_expected.to eq false }
    end

    context '出発場所が空白' do
      let(:departure_location) { '' }

      it { is_expected.to eq false }
    end

    context '備考欄が空白' do
      let(:note) { '' }
      it { is_expected.to eq true }
    end

    context '備考欄が1000文字' do
      let(:note) { 'a' * 1000 }

      it { is_expected.to eq true }
    end

    context '備考欄が1000文字以上' do
      let(:note) { 'a' * 1001 }

      it { is_expected.to eq false }
    end

    context 'スタッドレスタイヤの装着が未チェックの場合' do
      let(:is_studless_tire) { false }

      it { is_expected.to eq true }
    end

    context 'アルコール検査の実施が未チェックの場合' do
      let(:is_alcohol_check) { false }

      it { is_expected.to eq false }
    end
  end
end
