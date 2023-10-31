# frozen_string_literal: true

require 'nkf'

# ユーザー情報を管理するテーブル
class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token

  has_many :daily_logs

  validates :user_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 100 }, email_format: true
  validates :telephone, presence: true, length: { maximum: 11 }, numericality: { only_integer: true }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true, length: { minimum: 6 }
  validates :is_active, inclusion: { in: [true, false] }
  validates :is_admin, inclusion: { in: [true, false] }
  # バリデーション 大文字を含む passwordのバリデーションに追加する
  # ^(?=.*[A-Z])(?=.*[.?/-])[a-zA-Z0-9.?/-]{8,24}$ 大文字と記号のバリデーションを分ける
  # 不正な文字列バリデーションと大文字を含まないバリデーション

  after_initialize :format_user_name
  after_initialize :format_telephone
  after_initialize :format_email

  # daily_logのindexでユーザー名を一時的にnewで選択可能にするために使用。
  class << self
    def selectable_users
      all.map { |user| [user.user_name, user.id] }
    end
  end

  # ログインを保持するための設定
  # 与えられた値をハッシュ化する。
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost:)
  end

  # ランダムなトークンを作成する。
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # トークンを記憶する。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, '')
  end

  private

  def format_user_name
    return if user_name.blank?

    self.user_name = user_name.tr('　', ' ')
  end

  def format_telephone
    return if telephone.blank?

    self.telephone = telephone.tr('０-９', '0-9').delete('^0-9')
  end

  def format_email
    return if email.blank?

    self.email = NKF.nkf('-w -Z4', email)
  end
end
