require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class VehiclePosition < GTFS::Realtime::Model
      include GTFS::Realtime::Nearby

      many_to_one :stop
      many_to_one :trip
    end
  end
end
