# frozen_string_literal: true

require 'nkf'

# ユーザー情報を管理するテーブル
class User < ApplicationRecord
  include Discard::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # deviseの設定内容
  # パスワードをデータベースにハッシュ化して保存。:database_authenticatable
  # サインアップの設定。 :registerable
  # パスワードを復旧できる。 :recoverable
  # ユーザーを記憶するためのトークンの生成とクリアを管理する。 :rememberable
  # メールアドレスとパスワードのバリデーション。 :validatable

  # :validatable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :daily_logs, dependent: :destroy
  # has_many :frequent_destinations, dependent: :destroy
  has_many :favorite_vehicles, dependent: :destroy
  # has_many :vehicles, through: :favorite_vehicles

  validates :user_name, presence: true, length: { maximum: 50 }
  validates :telephone, presence: true, length: { maximum: 11 }, numericality: { only_integer: true }
  validates :discarded_at, presence: true, allow_blank: true
  validates :admin, inclusion: { in: [false, true] }
  validate :skip_email_validation_on_update, on: :update

  # devise使用のため、無効化。
  # validates :email, presence: true, length: { maximum: 100 }, email_format: true
  #  validates :password, length: { minimum: 6 }, allow_blank: true,
  #                      format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d][a-zA-Z0-9]+\z/, message: 'は半角英数字で入力してください' },
  #                      on: :registration
  # validates :password_confirmation, length: { minimum: 6 }, allow_blank: true,
  #                                   format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d][a-zA-Z0-9]+\z/, message: 'は半角英数字で入力してください' },
  #                                   on: :registration
  # validates :current_password, length: { minimum: 6 }, if: :password_required?
  # validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
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

  def frequent_destination
    DailyLog.where('user_id = ?', id)
  end

  def update_without_password(params, *options)
    params.delete(:current_password).blank?

    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?

    # result = if valid_password?(current_password)
    #   update_attributes(params, *options)
    # else
    #   self.assign_attributes(params, *options)
    #   self.valid?
    #   self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
    #   false
    # end

    result = update(params, *options)

    clean_up_passwords
    result
  end

  # ユーザー登録時のみパスワードのバリデーションを行うため、deviseのvalidatableをオーバーライド
  def self.included(base)
    base.extend ClassMethods
    assert_validations_api!(base)

    base.class_eval do
      validates_presence_of   :email, if: :email_required?
      validates_uniqueness_of :email, allow_blank: true, case_sensitive: true, if: :devise_will_save_change_to_email?
      validates_format_of     :email, with: email_regexp, allow_blank: true, if: :devise_will_save_change_to_email?

      validates_presence_of     :password, if: :password_required?, allow_nil: true if update
      validates_confirmation_of :password, if: :password_required?, allow_nil: true if update
      validates_length_of       :password, within: password_length, allow_blank: true
    end
  end

  # 論理削除されたユーザーをログインできなくする。
  def active_for_authentication?
    super && !discarded?
  end

  # ブックマーク機能
  # def registration_frequent_destinations(daily_log)
  #   frequent_destination << daily_log.arrival_location
  # end

  # def exclude_frequent_destinations(daily_log)
  #   frequent_destination.destroy(daily_log)
  # end

  # def frequent_destination?(daily_log)
  #   frequent_destination.include?(daily_log)
  # end

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

  def password_required?
    !persisted?
  end

  def skip_email_validation_on_update
    return unless email_changed?

    # メールアドレスが変更されている場合は、通常のバリデーションを行う
    validates_presence_of :email
  end
end
