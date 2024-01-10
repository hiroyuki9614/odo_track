class FavoriteVehiclesController < ApplicationController
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
    @favorite_vehicle = FavoriteVehicle.find(params[:id])
    @favorite_vehicle.destroy
    redirect_to root_path, status: :see_other
  end

  private

  def favorite_vehicle_params
    params.require(:favorite_vehicle).permit(:vehicle_id, :user_id, :favorite_vehicle_note)
  end
end
