# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザーの登録や編集に関するテスト', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, user_name: 'hogehoge') }
  let(:admin_user) { create(:user, admin: true) }
  let(:user_params) { attributes_for(:user) }
  let(:other_user_params) { attributes_for(:user, user_name: 'hogehoge') }
  let(:invalid_user_params) { attributes_for(:user, password_confirmation: '') }
  describe 'POST /user_registration' do
    before do
      ActionMailer::Base.deliveries.clear
    end
    context 'サインアップに必要なパラメータが妥当な場合' do
      it 'リクエストが成功する' do
        patch user_registration_path, params: { user: user_params }
        expect(response.status).to eq 302
      end

      it '認証メールが送信されること' do
        post user_registration_path, params: { user: user_params }
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end
      it 'createが成功すること' do
        expect do
          post user_registration_path, params: { user: user_params }
        end.to change(User, :count).by 1
      end

      it 'リダイレクトされること' do
        post user_registration_path, params: { user: user_params }
        expect(response).to redirect_to root_url
      end
    end
    context 'パラメータが不正な場合' do
      it 'リクエストが成功すること' do
        post user_registration_path, params: { user: invalid_user_params }
        expect(response.status).to eq 422
      end

      it '認証メールが送信されないこと' do
        post user_registration_path, params: { user: invalid_user_params }
        expect(ActionMailer::Base.deliveries.size).to eq 0
      end

      it 'createが失敗すること' do
        expect do
          post user_registration_path, params: { user: invalid_user_params }
        end.to_not change(User, :count)
      end

      it 'エラーが表示されること' do
        post user_registration_path, params: { user: invalid_user_params }
        expect(response.body).to include '*確認用パスワードとパスワードの入力が一致しません'
      end
    end

    context '管理者がユーザー情報を編集できること' do
      before do
        admin_user.confirm
        sign_in admin_user
      end
      it '他ユーザーの編集ページにアクセスできる' do
        get edit_other_user_registration_path(other_user)
        expect(response.status).to eq 200
      end
      context '一般ユーザーの場合' do
        before do
          user.confirm
          sign_in user
        end
        it 'リダイレクトされること' do
          get edit_other_user_registration_path(other_user)
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
