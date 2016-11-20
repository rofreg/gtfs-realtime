require "gtfs/realtime/stop/time_update"

module GTFS
  class Realtime
    class Stop
      attr_accessor :id, :name, :latitude, :longitude

      def initialize(gtfs, stop)
        @gtfs = gtfs
        @id = stop.id.strip
        @name = stop.name.strip
        @latitude = stop.lat.to_f
        @longitude = stop.lon.to_f
      end

      def trip_updates
        # find live trip updates that include this stop
        @gtfs.trip_updates.reject(&:is_deleted).select do |trip_update|
          trip_update.trip_update.stop_time_update.find{|stu| stu.stop_id.strip == id}
        end.collect do |trip_update|
          GTFS::Realtime::Stop::TimeUpdate.new(@gtfs, trip_update.trip_update, id)
        end
      end

      def inspect
        string = "#<Stop:#{id} \"#{name}\">"
      end
    end
  end
end
