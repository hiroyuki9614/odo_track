class FavoriteVehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_public_demo_vehicle, only: :create
  def new
    @favorite_vehicle = current_user.favorite_vehicles.build
  end

  def create
    @favorite_vehicle = FavoriteVehicle.new(favorite_vehicle_params)
    if @favorite_vehicle.user_id != current_user.id
      flash[:alert] = '不正な操作が行われました。'
      render :new and return
    end

    if @favorite_vehicle.save
      redirect_to daily_logs_path
    else
      # 失敗時にお気に入りを復旧。　恐らく不要。
      # @feed_items = current_user.feed
      render :new
    end
  end

  def destroy
    @favorite_vehicle = public_demo_account? ? current_user.favorite_vehicles.find(params[:id]) : FavoriteVehicle.find(params[:id])
    @favorite_vehicle.destroy
    redirect_to root_path, status: :see_other
  end

  private

  def favorite_vehicle_params
    permitted = params.require(:favorite_vehicle).permit(:vehicle_id, :user_id, :favorite_vehicle_note)
    permitted[:user_id] = current_user.id if public_demo_account?
    permitted
  end

  def authorize_public_demo_vehicle
    return unless public_demo_account?

    head :forbidden unless public_demo_vehicles.exists?(id: params.dig(:favorite_vehicle, :vehicle_id))
  end
end
