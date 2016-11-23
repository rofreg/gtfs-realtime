module GTFS
  class Realtime
    class TripUpdate < GTFS::Realtime::Model
      many_to_one :trip
      many_to_one :route
    end
  end
end
