# frozen_string_literal: true

require 'googleauth'

credentials = Google::Auth::UserRefreshCredentials.new(
  client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
  client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
  scope: [
    'https://www.googleapis.com/auth/drive',
    'https://spreadsheets.google.com/feeds/'
  ],
  redirect_uri: ENV.fetch('GOOGLE_REDIRECT_URI', 'http://localhost:3000/callback')
)
credentials.authorization_uri
