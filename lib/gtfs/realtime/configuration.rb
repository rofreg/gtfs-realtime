module GTFS
  class Realtime
    class Configuration
      attr_accessor :static_feed, :trip_updates_feed, :vehicle_positions_feed, :service_alerts_feed, :database_url

      def database_url=(new_path)
        @database_url = new_path
        ActiveRecord::Base.establish_connection(@database_url)
      end
    end
  end
end
