# frozen_string_literal: true

# 運転日報（Daily Logs）に関する操作（CRUDなど）を管理するコントローラーです。
# このコントローラーでは、運転日報の作成、編集、表示、削除等のアクションを定義しています。
module Api
  class ManagementVehiclesController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_user, except: %i[index]

    def index
      @q = Vehicle.where(discarded_at: nil).ransack(params[:q])
      @vehicles = @q.result(distinct: true).page params[:page]
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @discarded_vehicles = Vehicle.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
      render json: {
        vehicles: ActiveModelSerializers::SerializableResource.new(@vehicles, each_serializer: VehicleSerializer),
        discarded_vehicles: ActiveModelSerializers::SerializableResource.new(@discarded_vehicles,
                                                                             each_serializer: VehicleSerializer)
      }
    end

    def discarded_index
      @vehicles = Vehicle.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
      render json: {
        vehicles: ActiveModelSerializers::SerializableResource.new(@vehicles, each_serializer: VehicleSerializer)
      }
    end

    def create
      @vehicle = Vehicle.new(vehicle_params)

      if @vehicle.save
        render json: @vehicle, status: :created
      else
        render json: @vehicle.errors, status: :unprocessable_entity
      end
    end

    def update
      @vehicle = Vehicle.find(params[:id])

      if @vehicle.update(vehicle_params)
        render json: @vehicle, status: :ok
      else
        render json: @vehicle.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @vehicle = Vehicle.find(params[:id])
      if @vehicle.discard
        render json: @vehicle, status: :ok
      else
        render json: @vehicle.errors, status: :unprocessable_entity
      end
    end

    def undelete
      @vehicle = Vehicle.find(params[:id])
      if @vehicle.undiscard
        render json: @vehicle, status: :ok
      else
        render json: @vehicle.errors, status: :unprocessable_entity
      end
    end

    private

    def vehicle_params
      params.require(:management_vehicle).permit(:vehicle_name,
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
end
