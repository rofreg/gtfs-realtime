module GTFS
  class Realtime
    class ServiceAlert < GTFS::Realtime::Model
      many_to_one :stop
    end
  end
end
