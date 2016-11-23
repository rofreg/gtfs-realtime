module GTFS
  class Realtime
    class StopTime < GTFS::Realtime::Model
      many_to_one :trip
      many_to_one :stop
    end
  end
end
