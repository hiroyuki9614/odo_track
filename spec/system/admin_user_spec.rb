# frozen_string_literal: true

require 'rails_helper'
RSpec.describe '管理ユーザーの操作', type: :system do
  # before do
  #   visit users_path
  # end
  # let(:email) { Faker::Internet.unique.email } # ランダムなアドレスを取得するため再定義
  context '管理ユーザーとしての操作を行う' do
    it '管理ユーザーとして編集を行う' do
      @user = create(:user, admin: true)
      sign_in @user
      visit users_path
      click_link 'edit', match: :first
      fill_in 'お名前(フルネーム)', with: 'hogehoge'
      click_on '更新'
      expect(page).to have_content 'アカウント情報を変更しました。'
      @edited_user = User.find_by(user_name: 'hogehoge')
      expect(@edited_user.user_name).to eq 'hogehoge'
    end
  end
  context '一般ユーザーは編集ができない。' do
    it 'ユーザー一覧にアクセスできない' do
      @user = create(:user, admin: false)
      sign_in @user
      visit users_path
      expect(page).to have_content 'その操作は権限が無いため実行できません。'
      expect(current_path).to eq root_path
    end
  end
  context 'ログインしないと編集ができない。' do
    it 'ユーザー一覧にアクセスできない' do
      # @user = create(:user, admin: false)
      # sign_in @user
      # sign_out @user
      visit users_path
      expect(page).to have_content 'アカウント登録もしくはログインしてください。'
      expect(current_path).to eq new_user_session_path
    end
  end
end
