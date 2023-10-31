# frozen_string_literal: true

class AddRememberDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :remember_digest, :string, default: '', null: false, comment: '記憶トークン'
  end
end
