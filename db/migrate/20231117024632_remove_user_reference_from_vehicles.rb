class RemoveUserReferenceFromVehicles < ActiveRecord::Migration[7.1]
  def change
    # remove_reference :vehicles, :user, index: true, foreign_key: true
  end
end
