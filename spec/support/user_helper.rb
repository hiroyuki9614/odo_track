# frozen_string_literal: true

# @userのシステムテスト用ヘルパーメソッド
module UserHelpers
  def fill_in_user_forms
    # fill_in 'お名前(フルネーム)', with: @@user.@user_name テストのため省略
    fill_in 'メールアドレス', with: email
    fill_in '電話番号', with: @user.telephone
    fill_in 'パスワード', with: @user.password
    fill_in 'パスワード(確認)', with: @user.password_confirmation
  end

  def check_user_last_data
    @userdata = User.last
    expect(@userdata.user_name).to eq @user.user_name
    expect(@userdata.email).to eq email
    expect(@userdata.telephone).to eq @user.telephone
    # パスワードはハッシュ化されている。
    # expect(@user.password).to eq password
    # expect(@user.password_confirmation).to eq password_confirmation
    expect(@userdata.is_active).to eq true
    expect(@userdata.admin).to eq false
  end

  def expected_form_value_for_signup
    expect(current_path).to eq users_path
    expect(page).to have_field 'お名前(フルネーム)', with: @user.user_name
    expect(page).to have_field 'メールアドレス', with: email
    expect(page).to have_field '電話番号', with: @user.telephone
    expect(page).to have_field 'パスワード', with: @user.password
    expect(page).to have_field 'パスワード(確認)', with: @user.password_confirmation
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end
end
