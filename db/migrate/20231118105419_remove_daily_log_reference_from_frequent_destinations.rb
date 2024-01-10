class RemoveDailyLogReferenceFromFrequentDestinations < ActiveRecord::Migration[7.1]
  def change
    # remove_reference :frequent_destinations, :daily_log, foreign_key: true
  end
end
