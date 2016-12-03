module GTFS
  class Realtime
    class StopTimeUpdate < GTFS::Realtime::Model
      belongs_to :stop
      belongs_to :trip_update
      has_one :trip, through: :trip_update
      has_one :route, through: :trip_update

      def arrival_time
        super ? super.in_time_zone(Time.zone) : nil
      end

      def departure_time
        super ? super.in_time_zone(Time.zone) : nil
      end
    end
  end
end
