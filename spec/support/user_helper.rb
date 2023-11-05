# frozen_string_literal: true

# userのシステムテスト用ヘルパーメソッド
module UserHelpers
  def fill_in_user_forms
    # fill_in 'お名前(フルネーム)', with: user_name テストのため省略
    fill_in 'メールアドレス', with: email
    fill_in '電話番号', with: telephone
    fill_in 'パスワード', with: password
    fill_in 'パスワード(確認)', with: password_confirmation
  end

  def check_user_last_data
    user = User.last
    expect(user.user_name).to eq user_name
    expect(user.email).to eq email
    expect(user.telephone).to eq telephone
    # パスワードはハッシュ化されている。
    # expect(user.password).to eq password
    # expect(user.password_confirmation).to eq password_confirmation
    expect(user.is_active).to eq true
    expect(user.is_admin).to eq false
  end

  def expected_form_value_for_signup
    expect(current_path).to eq users_path
    expect(page).to have_field 'お名前(フルネーム)', with: user_name
    expect(page).to have_field 'メールアドレス', with: email
    expect(page).to have_field '電話番号', with: telephone
    expect(page).to have_field 'パスワード', with: password
    expect(page).to have_field 'パスワード(確認)', with: password_confirmation
  end

  def logged_in?
    !session[:user_id].nil?
  end
end
