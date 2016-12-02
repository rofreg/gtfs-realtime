module GTFS
  class Realtime
    class TripUpdate < GTFS::Realtime::Model
      belongs_to :trip
      belongs_to :route
    end
  end
end
