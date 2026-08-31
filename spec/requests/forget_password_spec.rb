# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'パスワードの再設定に関するテスト', type: :request do
  let(:user) { create(:user) }

  around do |example|
    original_options = Rails.application.config.action_mailer.default_url_options
    Rails.application.config.action_mailer.default_url_options = {
      host: 'odt.hiroyuki9614.com',
      protocol: 'https'
    }
    example.run
  ensure
    Rails.application.config.action_mailer.default_url_options = original_options
  end

  describe 'PATCH /user_password' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    context 'パスワードの再設定ができる' do
      it 'パスワードの再設定用メールが正しいURLと送信元で生成される' do
        post user_password_path, params: { user: { email: user.email } }

        expect(ActionMailer::Base.deliveries.size).to eq 1
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to include(user.email)
        expect(mail.from).to include('no-reply@mail.hiroyuki9614.com')
        expect(mail.body.encoded).to include('https://odt.hiroyuki9614.com')
        expect(mail.body.encoded).to include('reset_password_token=')

        ctoken = mail.body.match(/reset_password_token=([^\"]+)/)
        ftoken = mail.body.match(/(?<=reset_password_token=)[^\"]+/)
        get "/auth/secret/edit?#{ctoken}"
        patch user_password_path, params: { user: { password: 'abcdef',
                                                    password_confirmation: 'abcdef',
                                                    reset_password_token: ftoken } }
        post user_session_path, params: { user: { email: user.email, password: 'abcdef' } }
      end
    end

    context 'パスワードの再設定が失敗する。' do
      it '存在しないメールアドレスを送信する。' do
        post user_password_path, params: { user: { email: 'hoge@example.com' } }
        expect(response.status).to eq 422
      end

      it 'パスワードを空白にする' do
        post user_password_path, params: { user: { email: user.email } }
        mail = ActionMailer::Base.deliveries.last
        ctoken = mail.body.match(/reset_password_token=([^\"]+)/)
        ftoken = mail.body.match(/(?<=reset_password_token=)[^\"]+/)
        get "/auth/secret/edit?#{ctoken}"
        patch user_password_path, params: { user: { password: 'abcdef',
                                                    password_confirmation: '',
                                                    reset_password_token: ftoken } }
        expect(response.status).to eq 303
      end
    end
  end
end
