module GTFS
  class Realtime
    class Database
      class << self
        attr_writer :database_path

        def path=(new_path)
          @path = new_path

          # This script sets up an in-memory DB so that it can be used by this gem.
          # It also extends Sequel::Model so that Sequel may be used independently by
          # the parent project if desired.
          db = Sequel.connect(new_path || "sqlite://")

          # Set up all database tables
          db.create_table? :gtfs_realtime_routes do
            String :id, primary_key: true
            String :short_name
            String :long_name
            String :url

            index :id
          end

          db.create_table? :gtfs_realtime_shapes do
            String :id
            Integer :sequence
            Double :latitude
            Double :longitude

            index :id
          end

          db.create_table? :gtfs_realtime_stops do
            String :id, primary_key: true
            String :name
            Double :latitude
            Double :longitude

            index :id
          end

          db.create_table? :gtfs_realtime_stop_times do
            String :trip_id
            String :stop_id
            String :arrival_time
            String :departure_time
            Integer :stop_sequence

            index :trip_id
            index :stop_id
          end

          db.create_table? :gtfs_realtime_trips do
            String :id, primary_key: true
            String :headsign
            String :route_id
            String :service_id
            String :shape_id

            index :id
            index :route_id
          end

          db.create_table? :gtfs_realtime_trip_updates do
            String :id, primary_key: true
            String :trip_id
            String :route_id

            index :id
          end

          db.create_table? :gtfs_realtime_stop_time_updates do
            String :trip_update_id
            String :stop_id
            Integer :arrival_delay
            Time :arrival_time
            Integer :departure_delay
            Time :departure_time

            index :trip_update_id
            index :stop_id
          end

          db.create_table? :gtfs_realtime_vehicle_positions do
            String :trip_id
            String :stop_id
            Double :latitude
            Double :longitude
            Double :bearing
            Time :timestamp

            index :trip_id
            index :stop_id
          end

          db.create_table? :gtfs_realtime_service_alerts do
            String :stop_id
            String :header_text
            Text :description_text
            Time :start_time
            Time :end_time

            index :stop_id
          end

          # Set up all gtfs-realtime models to use this database
          model_classes.each do |model_class|
            model_class.db = db
          end
        end

        def model_classes
          ObjectSpace.each_object(::Class).select{|klass| klass <= GTFS::Realtime::Model}
        end
      end
    end
  end
end

# If we have not defined our model parent class yet, initialize it. Before we can
# load any other model files, we must have some sort of database set up, so we
# use an in-memory database for now. Later on, we can change this if we wish by
# setting `database_path` in a `GTFS::Realtime.configure` block.
if !defined?(GTFS::Realtime::Model)
  GTFS::Realtime::Model = Class.new(Sequel::Model)
  GTFS::Realtime::Model.plugin :many_through_many
  GTFS::Realtime::Database.path = nil

  class GTFS::Realtime::Model
    def self.implicit_table_name
      "gtfs_realtime_#{super}".to_sym
    end
  end
end