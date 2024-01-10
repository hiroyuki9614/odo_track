# frozen_string_literal: true

# 運転日報（Daily Logs）に関する操作（CRUDなど）を管理するコントローラーです。
# このコントローラーでは、運転日報の作成、編集、表示、削除等のアクションを定義しています。
class ManagementVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, except: %i[show index]
end
