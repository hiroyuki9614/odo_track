# frozen_string_literal: true

# 運転日報（Daily Logs）に関する操作（CRUDなど）を管理するコントローラーです。
# このコントローラーでは、運転日報の作成、編集、表示、削除等のアクションを定義しています。
class ManagementVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, except: %i[show index]

  def index
    @q = Vehicle.where(discarded_at: nil).ransack(params[:q])
    @vehicles = @q.result(distinct: true).page params[:page]
    @q.sorts = 'created_at desc' if @q.sorts.empty?
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

  def new
    @vehicle = Vehicle.new
  end

  def confirm
    if request.post?
      @vehicle = Vehicle.new(vehicle_params)
      session[:vehicle_data] = vehicle_params
    else
      @vehicle = Vehicle.new(session[:vehicle_data])
    end
    return unless @vehicle.invalid?

    render :new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    return render :new if params[:button] == 'back'

    if @vehicle.save
      redirect_to managment_vehicles_path
    else
      render :confirm
    end
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
  end

  def edit_confirm
    if request.patch?
      @vehicle = Vehicle.find(params[:id])
      session[:vehicle_data] = vehicle_params
      @vehicle.attributes = vehicle_params
    else
      # ここでセッションから取得したデータを属性にセット
      @vehicle = Vehicle.new(session[:vehicle_data])
    end
    return unless @vehicle.invalid?

    render :edit
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    if params[:button] == 'back'
      @vehicle.attributes = session[:vehicle_data]
      render :edit and return
    end
    if @vehicle.update(vehicle_params)
      redirect_to management_vehicles_path

    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.discard
    flash[:success] = '運転日報を削除しました。'
    redirect_to management_vehicles, status: :see_other
  end

  def delete
    @vehicle = Vehicle.find(params[:id])
    @vehicle.discard
    flash[:success] = '運転日報を削除しました。'
    redirect_to management_vehicles, status: :see_other
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:vehicle_name,
                                    :number,
                                    :manufacture,
                                    :current_drive_distance,
                                    :discarded_at)
  end

  def last_arrival_distance
    last_log = current_user.vehicles.last
    last_log&.arrival_distance.present? ? last_log.arrival_distance : ''
  end

  def admin_user
    return if user_signed_in? && current_user.admin?

    flash[:alert] = 'その操作は権限が無いため実行できません。'
    redirect_to(root_url, status: :see_other)
  end
end
