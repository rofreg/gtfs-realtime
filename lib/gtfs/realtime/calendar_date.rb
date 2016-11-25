module GTFS
  class Realtime
    class CalendarDate < GTFS::Realtime::Model
      ADDED = 1
      REMOVED = 2

      many_to_one :trip, primary_key: :service_id, key: :service_id
    end
  end
end