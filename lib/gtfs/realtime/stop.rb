require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class Stop < GTFS::Realtime::Model
      extend GTFS::Realtime::Nearby

      one_to_many :service_alerts
      one_to_many :stop_times
      one_to_many :stop_time_updates
      many_to_many :trip_updates, join_table: :gtfs_realtime_stop_time_updates
      many_to_many :trips, join_table: :gtfs_realtime_stop_times
      many_through_many :routes, through: [
        [:stop_times, :stop_id, :trip_id],
        [:trips, :id, :route_id]
      ]
      many_through_many :active_routes, class: GTFS::Realtime::Route, through: [
        [:stop_time_updates, :stop_id, :trip_update_id],
        [:trip_updates, :id, :route_id]
      ]

      def stop_times_schedule_for(date)
        # TODO: .all.first is a weird syntax to do eager loading correctly
        # Maybe there's a better way?
        self_with_eager_loads = GTFS::Realtime::Stop.where(id: id).eager(stop_times: {trip: [:calendar_dates, :route]}).all.first
        self_with_eager_loads.stop_times.select{|st| st.trip.active?(Date.today)}.sort_by{|st| st.departure_time}
      end

      def stop_times_for_today
        stop_times = stop_times_schedule_for(Date.today)
        stop_time_updates.each do |stu|
          # find a matching existing record in the schedule
          stop_time = stop_times.find{|st| st.trip_id == stu.trip_update.trip_id}

          # update its info
          stop_time.set(stu)
        end
        stop_times
      end
    end
  end
end