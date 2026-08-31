Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # all of your application code, giving you better performance and memory savings
  # via copy-on-write on supported servers.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.require_master_key = false

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', 'local').to_sym

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV.fetch('FORCE_SSL', 'false') == 'true'

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  config.action_mailer.perform_caching = false

  # Production mail is fail-loud by design. Devise confirmation/recovery must never
  # claim success while messages are silently routed to the test delivery adapter.
  # Missing/invalid SMTP credentials therefore surface as a delivery error when mail
  # is actually sent, while still allowing assets to be built without embedding secrets.
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  host = ENV.fetch('APP_DOMAIN', 'odt.hiroyuki9614.com')
  protocol = ENV.fetch('APP_PROTOCOL', 'https')
  config.action_mailer.default_url_options = {
    host: host,
    protocol: protocol
  }
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', 'smtp.resend.com'),
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    user_name: ENV.fetch('SMTP_USERNAME', 'resend'),
    password: ENV['SMTP_PASSWORD'],
    domain: ENV.fetch('SMTP_DOMAIN', host),
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.active_job.queue_adapter = :sidekiq

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to define the delay after a write.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
