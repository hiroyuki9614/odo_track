# frozen_string_literal: true

Devise.setup do |config|
  # The public sender is not a secret. SMTP credentials remain in the VPS-only
  # production environment and are never committed to the repository.
  config.mailer_sender = ENV.fetch('MAILER_FROM', 'ODO TRACK <no-reply@mail.hiroyuki9614.com>')

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12

  config.confirm_within = 1.day
  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.timeout_in = 1.day
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
