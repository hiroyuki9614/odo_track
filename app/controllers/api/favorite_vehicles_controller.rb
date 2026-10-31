module Api
  class FavoriteVehiclesController < ApplicationController
    before_action :authenticate_user!
    # before_action :admin_user, except: %i[show index]
    before_action :authorize_public_demo_vehicle, only: :create
    protect_from_forgery except: %i[create destroy]

    def index
      favorites = current_user.favorite_vehicles
      favorites = favorites.where(vehicle_id: public_demo_vehicles.select(:id)) if public_demo_account?
      @favorite_vehicles = favorites.order(created_at: :asc).page params[:page]
      @vehicles = public_demo_account? ? public_demo_vehicles.kept : Vehicle.kept
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
      @favorite_vehicle = current_user.favorite_vehicles.find(params[:id])

      if @favorite_vehicle.destroy
        render json: @favorite_vehicle, status: :no_content
      else
        render json: @favorite_vehicle.errors, status: :unprocessable_entity
      end
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
end
