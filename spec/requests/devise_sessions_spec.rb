# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'POST /user_session' do
    before do
      @user = create(:user)
    end

    context 'remember_meの動作確認' do
      it 'cookieにremember_meトークンが記録される。' do
        post user_session_path, params: { user: { email: @user.email, password: @user.password, remember_me: '1' } }
        expect(response).to redirect_to daily_logs_path
        expect(response.cookies['remember_user_token']).not_to be_nil
      end
    end
    context 'remember_meの動作確認' do
      it 'cookieにremember_meトークンが記録されない。' do
        post user_session_path, params: { user: { email: @user.email, password: @user.password, remember_me: '0' } }
        expect(response).to redirect_to daily_logs_path
        expect(response.cookies['remember_user_token']).to be_nil
      end
    end
  end
end
