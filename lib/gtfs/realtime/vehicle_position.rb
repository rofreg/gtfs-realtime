require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class VehiclePosition < GTFS::Realtime::Model
      include GTFS::Realtime::Nearby

      belongs_to :stop
      belongs_to :trip
    end
  end
end
