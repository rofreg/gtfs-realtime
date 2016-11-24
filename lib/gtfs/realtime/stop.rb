require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class Stop < GTFS::Realtime::Model
      extend GTFS::Realtime::Nearby

      one_to_many :service_alerts
      one_to_many :stop_times
      one_to_many :stop_time_updates
      many_to_many :trip_updates, join_table: :stop_time_updates
      many_to_many :trips, join_table: :stop_times
      many_through_many :routes, through: [
        [:stop_times, :stop_id, :trip_id],
        [:trips, :id, :route_id]
      ]
      many_through_many :active_routes, class: GTFS::Realtime::Route, through: [
        [:stop_time_updates, :stop_id, :trip_update_id],
        [:trip_updates, :id, :route_id]
      ]
    end
  end
end