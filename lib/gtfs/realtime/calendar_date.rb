module GTFS
  class Realtime
    class CalendarDate < GTFS::Realtime::Model
      ADDED = 1
      REMOVED = 2

      belongs_to :trip, primary_key: :service_id, foreign_key: :service_id
    end
  end
end