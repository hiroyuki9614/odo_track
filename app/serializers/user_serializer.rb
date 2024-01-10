class UserSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :email, :telephone, :admin, :confirmed_at, :discarded_at, :created_at

  def created_at
    object.created_at.strftime('%Y/%m/%d %H:%M')
  end

  def confirmed_at
    object.confirmed_at.present? ? '認証済' : '未認証'
  end
end
