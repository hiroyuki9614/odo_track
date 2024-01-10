# frozen_string_literal: true

module Api
  class DailyLogsForAdminController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_user

    def index
      @daily_logs = DailyLog.where(discarded_at: nil).order(created_at: :asc).includes(:vehicle).page params[:page]
      @discarded_daily_logs = DailyLog.where.not(discarded_at: nil).order(created_at: :asc).page params[:page]
      @vehicles = Vehicle.where(discarded_at: nil).order(created_at: :asc).page params[:page]
      vehicles_data = Vehicle.where(discarded_at: nil).map do |v|
        { vehicle_name: "#{v.vehicle_name} - #{v.number}", vehicle_id: v.id,
          vehicle_current_drive_distance: v.current_drive_distance }
      end
      render json: {
        daily_logs: ActiveModelSerializers::SerializableResource.new(@daily_logs, each_serializer: DailyLogsSerializer),
        discarded_daily_logs: ActiveModelSerializers::SerializableResource.new(@discarded_daily_logs,
                                                                               each_serializer: DailyLogsSerializer),
        vehicles: vehicles_data
      }
    end

    def update
      @daily_log = DailyLog.find(params[:id])

      if @daily_log.update(daily_log_params)
        render json: @daily_log, status: :ok
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @daily_log = DailyLog.find(params[:id])
      if @daily_log.destroy
        render json: @daily_log, status: :no_content
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
    end

    def delete
      @daily_log = DailyLog.find(params[:id])
      if @daily_log.discard
        render json: @daily_log, status: :ok
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
    end

    def undelete
      @daily_log = DailyLog.find(params[:id])
      if @daily_log.undiscard
        render json: @daily_log, status: :ok
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
    end

    private

    def daily_log_params
      params.require(:daily_logs_for_admin).permit(:id,
                                                   :departure_datetime,
                                                   :arrival_datetime,
                                                   :departure_distance,
                                                   :arrival_distance,
                                                   :departure_location,
                                                   :arrival_location,
                                                   :note,
                                                   :is_alcohol_check,
                                                   :is_studless_tire,
                                                   :approval_status,
                                                   :user_id,
                                                   :vehicle_id)
    end

    def admin_user
      return if user_signed_in? && current_user.admin?

      flash[:alert] = 'その操作は権限が無いため実行できません。'
      redirect_to(root_url, status: :see_other)
    end
  end
end
