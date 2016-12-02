module GTFS
  class Realtime
    class ServiceAlert < GTFS::Realtime::Model
      belongs_to :stop
    end
  end
end
