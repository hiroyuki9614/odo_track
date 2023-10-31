# frozen_string_literal: true

class AddReferenceUserIdToDailyLogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :daily_logs, :user, foreign_key: { on_update: :restrict, on_delete: :restrict }, comment: 'ユーザー参照'
  end
end
