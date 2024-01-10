# frozen_string_literal: true

module Api
  class DailyLogsController < ApplicationController
    before_action :authenticate_user!
    # protect_from_forgery except: %i[]

    def index
      page = params[:page] || 1
      @user = User.find(current_user.id)
      @q = @user.daily_logs.all.where(discarded_at: nil).ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @daily_logs = @q.result(distinct: true).includes(:vehicle).page(page)
      @total_pages = @daily_logs.total_pages
      favorite_vehicles_data = current_user.favorite_vehicles.includes(:vehicle).map do |fv|
        { vehicle_name: "#{fv.vehicle.vehicle_name} - #{fv.vehicle.number}", vehicle_id: fv.vehicle.id,
          vehicle_current_drive_distance: fv.vehicle.current_drive_distance }
      end
      render json: {
        daily_logs: ActiveModelSerializers::SerializableResource.new(@daily_logs, each_serializer: DailyLogsSerializer),
        favorite_vehicles: favorite_vehicles_data
      }
    end

    def new
      @daily_log = current_user.daily_logs.build(
        departure_datetime: Time.zone.today,
        arrival_datetime: Time.now.strftime('%Y-%m-%d %H:%M'),
        departure_location: DailyLog.kept.last.arrival_location
        # 乗った車(vehicle_id)の最後に記録された走行距離を入力するようにする。
        # 今は個人の最後の走行距離である。
      )
      # お気に入りの目的地をセレクトボックスで選べるようにする。 datalist要素
      render json: {
        daily_log: ActiveModelSerializers::SerializableResource.new(@daily_log, each_serializer: DailyLogSerializer)
      }
    end

    def create
      @daily_log = current_user.daily_logs.build(daily_log_params)

      if @daily_log.save
        render json: @daily_log, status: :created
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
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
      if @daily_log.discard
        render json: @daily_log, status: :no_content
      else
        render json: @daily_log.errors, status: :unprocessable_entity
      end
    end

    private

    def daily_log_params
      params.require(:daily_log).permit(:id,
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

    # def correct_user
    #   @daily_log = current_user.daily_logs.find_by(id: params[:id])
    #   return unless @daily_log.nil?

    #   flash[:alert] = '不正な操作が行われました。'

    #   redirect_to daily_logs_path, status: :see_other
    # end

    def last_arrival_distance
      last_log = current_user.daily_logs.last
      last_log&.arrival_distance.present? ? last_log.arrival_distance : ''
    end
  end
end
