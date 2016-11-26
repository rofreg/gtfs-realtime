module GTFS
  class Realtime
    class Configuration
      attr_accessor :static_feed, :trip_updates_feed, :vehicle_positions_feed, :service_alerts_feed, :database_path

      def database_path=(new_path)
        @database_path = new_path

        # now that we know the DB path, we can initialize the database
        require 'gtfs/realtime/database'
        GTFS::Realtime::Database.path = database_path

        # now that we have a database, initialize all the other models
        require 'gtfs/realtime/bootstrap'
      end
    end
  end
end
