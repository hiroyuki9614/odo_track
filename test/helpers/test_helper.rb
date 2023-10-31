# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
module ActiveSupport
  class TestCase
    # 指定のワーカー数でテストを並列実行する
    parallelize(workers: :number_of_processors)
    # test/fixtures/*.ymlのfixtureをすべてセットアップする
    fixtures :all

    # テストユーザーがログイン中の場合にtrueを返す
    def logged_in?
      !session[:user_id].nil?
    end
  end
end
