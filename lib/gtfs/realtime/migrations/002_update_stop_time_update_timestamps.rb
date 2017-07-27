class UpdateStopTimeUpdateTimestamps < ActiveRecord::Migration[5.0]
  def change
    change_column :gtfs_realtime_stop_time_updates, :arrival_time, :timestamp, null: true
    change_column :gtfs_realtime_stop_time_updates, :departure_time, :timestamp, null: true
  end
end
