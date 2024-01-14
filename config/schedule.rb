# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/environment') # Rails.root(Railsメソッド)を使用するために必要
rails_env = ENV['RAILS_ENV'] || :development # cronを実行する環境変数(:development, :product, :test)
set :environment, rails_env # cronを実行する環境変数をセット
set :output, "#{Rails.root}/log/crontab.log" # cronのログ出力用ファイル
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every :month, at: 'start of the month at midnight' do
  rake 'pdf_export:export_all'
end
every 1.minute do
  rake 'pdf_export:export_all'
end
# every 1.minute do
#   command "echo 'mossmossmossmossmossmoss'"
# end

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
