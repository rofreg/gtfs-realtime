module GTFS
  class Realtime
    class Configuration
      attr_accessor :static_feed, :trip_updates_feed, :vehicle_positions_feed, :service_alerts_feed, :database_path

      def database_path=(new_path)
        @database_path = new_path

        # reinitialize the database with the new path
        GTFS::Realtime::Database.path = database_path
      end
    end
  end
end
