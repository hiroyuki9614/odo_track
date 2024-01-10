module Api
  class FavoriteVehiclesController < ApplicationController
    before_action :authenticate_user!
    # before_action :admin_user, except: %i[show index]
    protect_from_forgery except: %i[create destroy]

    def index
      @favorite_vehicles = current_user.favorite_vehicles.order(created_at: :asc).page params[:page]
      @vehicles = Vehicle.kept
      render json: {
        favorite_vehicles: ActiveModelSerializers::SerializableResource.new(@favorite_vehicles,
                                                                            each_serializer: FavoriteVehicleSerializer),
        vehicles: ActiveModelSerializers::SerializableResource.new(@vehicles, each_serializer: VehicleSerializer)
      }
    end

    def create
      @favorite_vehicle = current_user.favorite_vehicles.build(favorite_vehicle_params)

      if @favorite_vehicle.save
        render json: @favorite_vehicle, status: :created
      else
        render json: @favorite_vehicle.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @favorite_vehicle = FavoriteVehicle.find(params[:id])

      if @favorite_vehicle.destroy
        render json: @favorite_vehicle, status: :no_content
      else
        render json: @favorite_vehicle.errors, status: :unprocessable_entity
      end
    end

    private

    def favorite_vehicle_params
      params.require(:favorite_vehicle).permit(:vehicle_id, :user_id, :favorite_vehicle_note)
    end
  end
end
