# frozen_string_literal: true

# 検索機能
class SearchKeyword
  include ActiveModel::Model

  attr_accessor :keyword

  validates :keyword, presence: true
end
