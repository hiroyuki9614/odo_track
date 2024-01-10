# frozen_string_literal: true

# ユーザーのお気に入り管理を行うコントローラー
class UsersController < ApplicationController
  before_action :authenticate_user!
  # before_action :admin_user, only: %i[index destroy]
end
