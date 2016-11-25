module GTFS
  class Realtime
    class StopTimeUpdate < GTFS::Realtime::Model
      one_through_one :route, join_table: :gtfs_realtime_trip_updates, left_key: :id, left_primary_key: :trip_update_id, right_key: :route_id
      many_to_one :stop
      one_through_one :trip, join_table: :gtfs_realtime_trip_updates, left_key: :id, left_primary_key: :trip_update_id, right_key: :trip_id
      many_to_one :trip_update
    end
  end
end
