require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'POST /login' do
    let(:user) { FactoryBot.create(:user) } # テスト用のユーザーを作成

    context 'with remember_me checked' do
      it 'sets the remember_me cookie' do
        post login_path, params: { session: { email: user.email, password: user.password, remember_me: '1' } }
        expect(response.cookies['remember_token']).not_to be_nil
        # remember_me クッキーがセットされているかを確認
      end
    end
  end
end
