# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '4.3.6'

# 環境変数を管理する
gem 'dotenv-rails', '>=2.8.1'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem 'importmap-rails'

# railsにvite.jsを導入する
gem 'vite_rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# デコレーター
gem 'active_decorator'

# 多言語対応
gem 'rails-i18n', '~> 7.0.0'

# 非同期処理
gem 'sidekiq'

# ページネーション
gem 'kaminari'

# ページネーションにbootstrap5を適用
gem 'bootstrap5-kaminari-views'

# enumのi18n対応
gem 'enum_help'

# パスワードのハッシュ化
gem 'bcrypt', '~> 3.1', require: 'bcrypt'

gem 'mini_racer'

# pdfを作成する
gem 'matrix'
gem 'prawn'
gem 'prawn-table'

# ユーザー認証。
gem 'devise'

# 論理削除を実装する。
gem 'discard', '~> 1.2'

# 検索機能とソート機能
gem 'ransack'

# フロントエンドとバックエンドの連携に使用する。
# クロスドメイン AJAX 呼び出しを行う
gem 'rack-cors'

# railsがAPIモードの際に生成されるJSONファイルを整形する。
gem 'active_model_serializers', '~> 0.10.0'

# 定期的にスクリプトを実行する
gem 'whenever', require: false

# テストデータの作成
gem 'faker'

# gem 'aws-sdk-s3', require: false

# google API
# gem 'google-apis-drive_v3', '~> 0.5.0'

# googleのOAuthクライアントライブラリ
# gem 'googleauth'

# スプレッドシートにデータを保存・pdf化
# gem 'google_drive'

# 本番環境でPostgreSQLデータベースを使用する
group :production do
  gem 'pg', '1.1.4'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
  gem 'sqlite3', '~> 1.4'
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem 'foreman'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end
