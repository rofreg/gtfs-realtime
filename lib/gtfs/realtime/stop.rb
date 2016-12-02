require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class Stop < GTFS::Realtime::Model
      include GTFS::Realtime::Nearby

      has_many :service_alerts
      has_many :stop_times
      has_many :stop_time_updates
      has_many :trips, through: :stop_times
      has_many :trip_updates, through: :stop_times

      # many_through_many :routes, through: [
      #   [:gtfs_realtime_stop_times, :stop_id, :trip_id],
      #   [:gtfs_realtime_trips, :id, :route_id]
      # ]
      # many_through_many :active_routes, class: GTFS::Realtime::Route, through: [
      #   [:gtfs_realtime_stop_time_updates, :stop_id, :trip_update_id],
      #   [:gtfs_realtime_trip_updates, :id, :route_id]
      # ]

      def stop_times_schedule_for(date)
        stop_times.includes(trip: [:calendar_dates, :route, :shapes]).select{|st| st.trip.active?(date)}.sort_by{|st| st.departure_time}
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