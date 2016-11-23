module GTFS
  class Realtime
    class Stop < GTFS::Realtime::Model
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

      def self.nearby(latitude, longitude)
        # TODO: this math is terrible! It'll fail for various edge cases.
        # (e.g. close to the poles, overlapping to the prime meridian)
        # That said, it's an okay approximation within the United States.

        all.select do |stop|
          (stop.latitude - latitude).abs < 0.01 &&
            (stop.longitude - longitude).abs < 0.01
        end
      end
    end
  end
end