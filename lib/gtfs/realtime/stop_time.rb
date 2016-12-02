module GTFS
  class Realtime
    class StopTime < GTFS::Realtime::Model
      many_to_one :trip
      many_to_one :stop

      attr_accessor :actual_arrival_time, :actual_arrival_delay, :actual_departure_time, :actual_departure_delay
      attr_accessor :mod_type

      def live?
        actual_arrival_time || actual_arrival_delay || actual_departure_time || actual_departure_delay
      end

      def arrival_time
        actual_arrival_time || scheduled_arrival_time
      end

      def departure_time
        actual_departure_time || scheduled_departure_time
      end

      def scheduled_arrival_time
        self.class.parse_time(self[:arrival_time])
      end

      def scheduled_departure_time
        self.class.parse_time(self[:departure_time])
      end

      def set(val)
        @mod_type = "set"
        return super(val) unless val.is_a?(GTFS::Realtime::StopTimeUpdate)

        @actual_arrival_time = val.arrival_time
        @actual_arrival_delay = val.arrival_delay
        @actual_departure_time = val.departure_time
        @actual_departure_delay = val.departure_delay
      end

      def set_delay(stop_time_update)
        @mod_type = "set_delay"
        @actual_arrival_delay = stop_time_update.arrival_delay
        puts "Actual arrival delay, carried over: #{@actual_arrival_delay}"
        @actual_arrival_time = scheduled_arrival_time + @actual_arrival_delay if @actual_arrival_delay
        @actual_departure_delay = stop_time_update.departure_delay
        @actual_departure_time = scheduled_departure_time + @actual_departure_delay if @actual_departure_delay
      end

      def mark_as_departed
        @mod_type = "mark_as_departed"

        # if we've already passed the scheduled time, no need to change anything
        return if arrival_time < Time.now - 60 && departure_time < Time.now - 60

        # but if we haven't passed the scheduled time (e.g. the bus came and left early), we need to adjust
        @actual_arrival_time = Time.now - 60
        @actual_arrival_delay = @actual_arrival_time - Time.now
        @actual_departure_time = Time.now - 60
        @actual_departure_delay = @actual_departure_time - Time.now
      end

      private

      def self.parse_time(time, date = Date.today)
        # TODO: handle case where date != Date.today
        day_adjustment = 0
        hour = time[0...2].to_i

        # handle timestamps like "24:30"
        if hour >= 24
          days = hour / 24
          time[0...2] = (hour % 24).to_s.rjust(2, '0')
        end

        Time.parse(time) + day_adjustment * 60 * 60 * 24
      end
    end
  end
end
