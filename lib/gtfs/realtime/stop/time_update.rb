module GTFS
  class Realtime
    class Stop
      class TimeUpdate
        attr_accessor :stop_id, :trip_id, :time, :delay

        def initialize(gtfs, trip_update, stop_id)
          @gtfs = gtfs
          @trip_id = trip_update.trip.trip_id.strip
          @stop_id = stop_id.strip

          stop_time_update = trip_update.stop_time_update.find{|stu| stu.stop_id.strip == stop_id}
          @time = Time.at(stop_time_update.departure.time)
          @delay = stop_time_update.departure.delay.to_i
        end

        def trip
          @gtfs.trips.find{|t| t.id == trip_id}
        end

        def inspect
          delay_string = case
            when delay < 0
              ", #{delay / 60} minutes early"
            when delay > 0
              ", #{delay / 60} minutes late"
            end

          string = "#<Stop::TimeUpdate:#{stop_id}/#{trip_id} \"#{time.strftime('%b %e at %I:%M%p')}#{delay_string}\">"
        end
      end
    end
  end
end
