# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'パスワードの再設定に関するテスト', type: :request do
  let(:user) { create(:user) }
  describe 'PATCH /user_password' do
    before do
      ActionMailer::Base.deliveries.clear
    end
    context 'パスワードの再設定ができる' do
      it 'パスワードの再設定用メールが送信される' do
        post user_password_path, params: { user: { email: user.email } }
        # expect(response.body).to include '*アカウントの有効化について数分以内にメールでご連絡します。'
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(ActionMailer::Base.deliveries.last.to).to include user.email

        ctoken = ActionMailer::Base.deliveries.last.body.match(/reset_password_token=([^"]+)/)
        ftoken = ActionMailer::Base.deliveries.last.body.match(/(?<=reset_password_token=)[^"]+/)
        get "/auth/secret/edit?#{ctoken}"
        expect(response.body).to include 'Change your password'
        patch user_password_path, params: { user: { password: 'abcdef',
                                                    password_confirmation: 'abcdef',
                                                    reset_password_token: ftoken } }
        # 変更したパスワードでログインができる。
        post user_session_path, params: { user: { email: user.email, password: 'abcdef' } }
        expect(response).to redirect_to daily_logs_path
      end
    end
    context 'パスワードの再設定が失敗する。' do
      it '存在しないメールアドレスを送信する。' do
        post user_password_path, params: { user: { email: 'hoge@example.com' } }
        expect(response.status).to eq 422
      end
      it 'パスワードを空白にする' do
        post user_password_path, params: { user: { email: user.email } }
        ctoken = ActionMailer::Base.deliveries.last.body.match(/reset_password_token=([^"]+)/)
        ftoken = ActionMailer::Base.deliveries.last.body.match(/(?<=reset_password_token=)[^"]+/)
        get "/auth/secret/edit?#{ctoken}"
        patch user_password_path, params: { user: { password: 'abcdef',
                                                    password_confirmation: '',
                                                    reset_password_token: ftoken } }
        expect(response.status).to eq 303
      end
    end
  end
end
