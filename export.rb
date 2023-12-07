# frozen_string_literal: true

require 'googleauth'

credentials = Google::Auth::UserRefreshCredentials.new(
  client_id: '948718533666-p97dgh1i0nle94o53bcs1cbdpbahk8a7.apps.googleusercontent.com',
  client_secret: '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',
  scope: [
    'https://www.googleapis.com/auth/drive',
    'https://spreadsheets.google.com/feeds/'
  ],
  redirect_uri: 'http://localhost:3000/callback'
)
credentials.authorization_uri
