# frozen_string_literal: true

class ChangUsersColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_digest, :string, null: false, comment: 'パスワード'

    remove_column :users, :password_hash, :string, null: false, comment: 'パスワード(ハッシュ化)'
  end
end
