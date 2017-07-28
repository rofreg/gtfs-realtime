module GTFS
  class Realtime
    class StopTime < GTFS::Realtime::Model
      belongs_to :trip
      has_one :trip_update, through: :trip
      belongs_to :stop

      attr_accessor :actual_arrival_time, :actual_arrival_delay, :actual_departure_time, :actual_departure_delay

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
        return super(val) unless val.is_a?(GTFS::Realtime::StopTimeUpdate)

        @actual_arrival_time = val.arrival_time
        @actual_arrival_time ||= scheduled_arrival_time + val.arrival_delay if val.arrival_delay
        @actual_arrival_delay = val.arrival_delay
        @actual_departure_time = val.departure_time
        @actual_departure_time ||= scheduled_departure_time + val.departure_delay if val.departure_delay
        @actual_departure_delay = val.departure_delay
      end

      private

      def self.parse_time(time, date = Date.today)
        day_adjustment = 0
        hour = time[0...2].to_i

        # handle timestamps like "24:30"
        if hour >= 24
          days = hour / 24
          time[0...2] = (hour % 24).to_s.rjust(2, '0')
        end

        Time.parse("#{date} #{time}").in_time_zone(Time.zone) + day_adjustment * 60 * 60 * 24
      end
    end
  end
end
