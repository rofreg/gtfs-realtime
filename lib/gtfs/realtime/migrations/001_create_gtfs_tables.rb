class CreateGtfsTables < ActiveRecord::Migration[5.0]
  def change
    create_table :gtfs_realtime_calendar_dates, id: false do |t|
      t.string :service_id, index: true
      t.date :date
      t.integer :exception_type
    end

    create_table :gtfs_realtime_routes do |t|
      t.string :short_name
      t.string :long_name
      t.string :url
    end
    change_column :gtfs_realtime_routes, :id, :string

    create_table :gtfs_realtime_shapes, id: false do |t|
      t.string :id  # NOT unique
      t.integer :sequence
      t.float :latitude
      t.float :longitude

      t.index [:id, :sequence]
    end

    create_table :gtfs_realtime_stops do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
    end
    change_column :gtfs_realtime_stops, :id, :string

    create_table :gtfs_realtime_stop_times, id: false do |t|
      t.string :trip_id, index: true
      t.string :stop_id, index: true
      t.string :arrival_time
      t.string :departure_time
      t.integer :stop_sequence
    end

    create_table :gtfs_realtime_trips do |t|
      t.string :headsign
      t.string :route_id, index: true
      t.string :service_id
      t.string :shape_id
      t.integer :direction_id
    end
    change_column :gtfs_realtime_trips, :id, :string

    create_table :gtfs_realtime_trip_updates do |t|
      t.string :trip_id
      t.string :route_id
    end
    change_column :gtfs_realtime_trip_updates, :id, :string

    create_table :gtfs_realtime_stop_time_updates, id: false do |t|
      t.string :trip_update_id, index: true
      t.string :stop_id, index: true
      t.integer :arrival_delay
      t.timestamp :arrival_time
      t.integer :departure_delay
      t.timestamp :departure_time
    end

    create_table :gtfs_realtime_vehicle_positions, id: false do |t|
      t.string :trip_id, index: true
      t.string :stop_id, index: true
      t.float :latitude
      t.float :longitude
      t.float :bearing
      t.timestamp :timestamp
    end

    create_table :gtfs_realtime_service_alerts, id: false do |t|
      t.string :stop_id, index: true
      t.string :header_text
      t.text :description_text
      t.timestamp :start_time
      t.timestamp :end_time
    end
  end
end
