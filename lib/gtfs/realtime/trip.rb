require "gtfs/realtime/stop/time_update"

module GTFS
  class Realtime
    class Trip
      attr_accessor :id, :headsign, :route_id, :service_id, :shape_id

      def initialize(gtfs, trip)
        @gtfs = gtfs
        @id = trip.id.strip
        @headsign = trip.headsign.strip
        @route_id = trip.route_id.strip
        @service_id = trip.service_id.strip
        @shape_id = trip.shape_id.strip
      end

      def route
        raise "TODO"
      end

      def shape
        raise "TODO"
      end

      def inspect
        string = "#<Trip:#{id} \"#{headsign}\">"
      end
    end
  end
end
