module GTFS
  class Realtime
    class StopTimeUpdate < GTFS::Realtime::Model
      belongs_to :stop
      belongs_to :trip_update
      has_one :trip, through: :trip_update
      has_one :route, through: :trip_update
    end
  end
end
