module GTFS
  class Realtime
    class CalendarDate < GTFS::Realtime::Model
      ADDED = 1
      REMOVED = 2

      def trip
        # TODO: can this be made into a Sequel association?
        GTFS::Realtime::Trip.where(service_id: service_id).first
      end
    end
  end
end