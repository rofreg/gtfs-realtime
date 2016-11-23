module GTFS
  class Realtime
    class Configuration
      attr_accessor :static_feed, :trip_updates_feed, :vehicle_positions_feed, :service_alerts_feed
    end
  end
end
