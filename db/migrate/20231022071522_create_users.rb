class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :user_name, null: false, comment: 'お名前'
      t.string :email, null: false, comment: 'メールアドレス'
      t.string :telephone, null: false, comment: '電話番号'
      t.string :password_hash, null: false, comment: 'パスワード(ハッシュ化)'
      t.boolean :is_active, null: false, default: true, comment: '社員の在籍状況'
      t.boolean :is_admin, null: false, default: false, comment: '管理者権限'

      t.timestamps
    end
  end
end
