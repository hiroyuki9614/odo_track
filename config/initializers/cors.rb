# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allowed_origins = ENV.fetch('CORS_ORIGINS', '').split(',').map(&:strip).reject(&:empty?)
  next if allowed_origins.empty?

  allow do
    origins(*allowed_origins)
    resource '*',
             headers: %w[Accept Content-Type X-CSRF-Token],
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
