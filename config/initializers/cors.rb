# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins 'http://0.0.0.0:3000' # 許可するオリジン（ドメイン）を指定
    # origins 'https://h9614.link/'
    origins '*'
    resource '*', # すべてのリソースに適用
             headers: :any, # すべてのヘッダーを許可
             methods: :any, # 許可するHTTPメソッド
             credentials: false # クッキーを含むリクエストを許可
  end
end
