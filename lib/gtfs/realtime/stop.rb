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
      has_many :routes, through: :trips
      has_many :active_routes, through: :trip_updates, source: :route

      def stop_times_schedule_for(date)
        stop_times.includes(trip: [:calendar_dates, :route]).select{|st| st.trip.active?(date)}.sort_by{|st| st.departure_time}
      end

      def stop_times_for_today
        stop_times = stop_times_schedule_for(Date.today)
        stop_time_updates.includes(:trip_update).each do |stu|
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