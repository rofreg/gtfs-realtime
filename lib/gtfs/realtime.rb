require "google/transit/gtfs-realtime.pb"
require "gtfs"

require "gtfs/realtime/nearby"
require "gtfs/realtime/stop"
require "gtfs/realtime/trip"
require "gtfs/realtime/version"

module GTFS
  class Realtime
    extend Forwardable
    include Nearby

    TRIP_UPDATES_FEED = "/api/tripupdates"
    VEHICLE_POSITIONS_FEED = "/api/vehiclepositions"
    SERVICE_ALERTS_FEED = "/api/servicealerts"

    def_delegators :@static_source, :routes, :shapes, :stops, :stop_times, :trips

    def initialize(gtfs_static_feed, gtfs_realtime_root_url)
      @static_source = GTFS::Source.build(gtfs_static_feed)
      @root_url = gtfs_realtime_root_url
    end

    def update!
      @trip_updates = @vehicle_positions = @alerts = nil
    end

    def static_source
      @static_source
    end

    def trip_updates
      @trip_updates ||= get_entities(TRIP_UPDATES_FEED)
    end

    def vehicle_positions
      @vehicle_positions ||= get_entities(VEHICLE_POSITIONS_FEED)
    end

    def alerts
      @alerts ||= get_entities(SERVICE_ALERTS_FEED)
    end

    def stops
      static_source.stops.collect do |stop|
        GTFS::Realtime::Stop.new(self, stop)
      end
    end

    def trips
      static_source.trips.collect do |trip|
        GTFS::Realtime::Trip.new(self, trip)
      end
    end

    private

    def get_entities(path)
      data = Net::HTTP.get(URI.parse(@root_url+path))
      feed = Transit_realtime::FeedMessage.decode(data)
      feed.entity   # array of entities
    end
  end
end
