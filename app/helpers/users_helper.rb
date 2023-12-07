module UsersHelper
  def update_without_password(params, *options)
    params.delete(:password)
    params.delete(:password_confirmation)

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end
end
