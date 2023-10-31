# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Userテーブルのテストデータ
  describe '#valid?' do
    let(:user_name) { 'テスト太郎' } # 氏名
    let(:email) { 'mmnnoov@gmail.com' } # メールアドレス
    let(:telephone) { '09051691918' } # 電話番号
    let(:password) { 'aaaaaa' } # パスワード
    let(:password_confirmation) { 'aaaaaa' } # パスワード(確認)
    let(:is_active) { true } # ユーザーの在籍
    let(:is_admin) { false } # 管理者権限
    let(:params) do
      {
        user_name:,
        email:,
        telephone:,
        password:,
        password_confirmation:,
        is_active:,
        is_admin:
      }
    end

    it '返り値はtrueになること' do
      user = User.new(params)
      expect(user.valid?).to eq(true),
                             "Expected User to be valid, but got errors: #{user.errors.full_messages.to_sentence}"
    end

    subject { User.new(params).valid? }

    it { is_expected.to eq true }

    # paramsの部分的なバリデーションチェック
    context '名前が空白' do
      let(:user_name) { '' }

      it { is_expected.to eq false }
    end

    context '名前が50文字以下' do
      let(:user_name) { 'あ' * 50 }
      it { is_expected.to eq true }
    end

    context '名前が50文字以上' do
      let(:user_name) { 'あ' * 51 }
      it { is_expected.to eq false }
    end

    context 'メールアドレスが空白' do
      let(:email) { '' }

      it { is_expected.to eq false }
    end

    context 'メールアドレスのバリデーションチェック' do
      let(:email) { 'mmm.mmm@gmail.com' }
      let(:email) { 'mmm.mmm@gmail.jp' }
      let(:email) { 'mmm.mmm@gmail.net' }
      let(:email) { 'mmm.mmm@docomo.ne.jp' }
      let(:email) { 'mmm.mmm@gmail.co.jp' }

      it { is_expected.to eq true }
    end

    context 'メールアドレスの形式が不正' do
      let(:email) { 'mmm@gmailcom' }
      let(:email) { 'mmmgmailcom' }
      it { is_expected.to eq false }
    end

    context 'メールアドレスが全角' do
      let(:email) { 'ｍｍｍ@ｇｍａｉｌ.ｃｏｍ' }
      it { is_expected.to eq true }
    end

    context '電話番号が空白' do
      let(:telephone) { '' }

      it { is_expected.to eq false }
    end

    context '電話番号が11文字' do
      let(:telephone) { '09012341234' }

      it { is_expected.to eq true }
    end

    context '電話番号が11文字以上' do
      let(:telephone) { '090123412341' }

      it { is_expected.to eq false }
    end

    context '電話番号が全角' do
      let(:telephone) { '０９０００００１１１１' }

      it { is_expected.to eq true }
    end

    context '電話番号に数字以外が含まれている' do
      let(:telephone) { '090ー1234-1234' }

      it { is_expected.to eq true }
    end

    context 'パスワードが空白' do
      let(:password) { '' }

      it { is_expected.to eq false }
    end

    context 'パスワードが6文字以下' do
      let(:password) { 'aaaaa' }

      it { is_expected.to eq false }
    end

    context 'パスワード(確認)が空白' do
      let(:password_confirmation) { '' }

      it { is_expected.to eq false }
    end

    context 'パスワード(確認)が6文字以下' do
      let(:password_confirmation) { 'aaaaa' }

      it { is_expected.to eq false }
    end

    context 'パスワードが一致しない' do
      let(:password_confirmation) { 'aaaaaa' }
      let(:password_confirmation) { 'aaaaab' }

      it { is_expected.to eq false }
    end

    describe 'methods' do
      describe '#digest' do
        it '与えられた文字列に対するBCryptハッシュを返す。' do
          string = 'password'
          hash = User.digest(string)

          expect(BCrypt::Password.new(hash)).to be_truthy
          expect(BCrypt::Password.new(hash).is_password?(string)).to be_truthy
        end
      end

      describe '#new_token' do
        it 'cookieに保存するランダムなキーの動作チェック' do
          token = User.new_token
          expect(token).to be_a(String)
          expect(token).not_to be_empty
        end
      end
    end

    context '在籍状況がnil' do
      let(:is_active) { '' }

      it { is_expected.to eq false }
    end
    context '管理者権限がnil' do
      let(:is_admin) { '' }

      it { is_expected.to eq false }
    end
  end
end
