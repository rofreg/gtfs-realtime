require "gtfs/realtime/nearby"

module GTFS
  class Realtime
    class Stop < GTFS::Realtime::Model
      include GTFS::Realtime::Nearby

      one_to_many :service_alerts
      one_to_many :stop_times
      one_to_many :stop_time_updates
      many_to_many :trip_updates, join_table: :gtfs_realtime_stop_times, right_key: :trip_id, right_primary_key: :trip_id
      many_to_many :trips, join_table: :gtfs_realtime_stop_times

      many_through_many :routes, through: [
        [:gtfs_realtime_stop_times, :stop_id, :trip_id],
        [:gtfs_realtime_trips, :id, :route_id]
      ]
      many_through_many :active_routes, class: GTFS::Realtime::Route, through: [
        [:gtfs_realtime_stop_time_updates, :stop_id, :trip_update_id],
        [:gtfs_realtime_trip_updates, :id, :route_id]
      ]

      def stop_times_schedule_for(date)
        # TODO: .all.first is a weird syntax to do eager loading correctly. Maybe there's a better way?
        self_with_eager_loads = GTFS::Realtime::Stop.where(id: id).eager(stop_times: {trip: [:calendar_dates, :route, :shapes]}).all.first
        self_with_eager_loads.stop_times.select{|st| st.trip.active?(Date.today)}.sort_by{|st| st.departure_time}
      end

      def stop_times_for_today
        stop_times = stop_times_schedule_for(Date.today)
        trip_updates = self.trip_updates

        # for each StopTime, let's see if there's updated live information
        stop_times.each do |stop_time|
          # check for a matching live StopTimeUpdate
          stop_time_update = stop_time_updates.find{|stu| stop_time.trip_id == stu.trip_update.trip_id}

          if stop_time_update
            # if we found a match, update our arrival/departure time info in memory and return
            stop_time.set(stop_time_update)
            next
          end

          # even if there's NOT a live StopTimeUpdate, there may be a TripUpdate.
          # this would indicate that the route is currently live.
          trip_update = trip_updates.find{|tu| stop_time.trip_id == tu.trip_id}

          # if there's no TripUpdate, this trip just isn't active right now
          next if !trip_update

          puts "TRIP UPDATE FOUND FOR TRIP ##{stop_time.trip_id}"

          # because there is a TripUpdate, we KNOW that this trip is active.
          # that means that either:
          # - the stop has already been passed, or
          # - the StopTripUpdate data is sparse, and we need to infer the delay from an earlier stop

          earlier_stop =  GTFS::Realtime::StopTime
                            .order(Sequel.desc(:stop_sequence))
                            .where(trip_id: trip_update.trip_id)
                            .where("stop_sequence < ?", stop_time.stop_sequence)
                            .first

          puts "TRIPUPDATE ID: #{trip_update.id}"
          puts "STOP SEQUENCE: #{stop_time.stop_sequence}"

          earlier_stop_time_update = GTFS::Realtime::StopTimeUpdate.join(:gtfs_realtime_stop_times, stop_id: :stop_id).where(trip_update_id: trip_update.id, trip_id: trip_update.trip_id).order(Sequel.desc(:stop_sequence)).where("stop_sequence < ?", stop_time.stop_sequence).first
          puts "EARLIER STOP TIME UPDATE TRIP ID: #{earlier_stop_time_update.trip.id}" if earlier_stop_time_update

          if earlier_stop_time_update
            puts "CURRENT STOP SEQUENCE FOUND: #{stop_time.stop_sequence}"
            earlier_stop_time_update.trip.stop_times.each do |s|
              puts "EARLIER STOP SEQUENCE FOUND: #{s.stop_sequence}" if s.stop_id == earlier_stop_time_update.stop_id
            end
            # infer the delay from earlier_stop_time_update
            stop_time.set_delay(earlier_stop_time_update)
          else
            # this stop has passed already
            # TODO: does this not apply to the first stop on the trip?
            # https://developers.google.com/transit/gtfs-realtime/guides/trip-updates
            # https://github.com/google/transit/pull/16
            # https://github.com/OneBusAway/onebusaway-application-modules/pull/142
            stop_time.mark_as_departed
          end


          # # there are a few possibilities.
          # # for example, the bus may have arrived early and already departed.
          # # in that case, we will NOT have a StopTimeUpdate, but a TripUpdate will exist for the trip
          # # TODO: technically, the stop may not have happened yet if the trip_update data is sparse;
          # # i.e. if the trip_update does not include realtime data for every stop





          # # TODO: load all stops on trip, in order by stop_sequence
          # # go backwards from self.id, looking for stop_time_updates
          # # once we find one, apply the delay
          # potential_stop_times = GTFS::Realtime::StopTime.order(Sequel.desc(:stop_sequence)).where(trip_id: trip_update.trip_id).all
          # backtracked_to_this_stop = false
          # found_earlier_stop_time_update = false

          # potential_stop_times.each do |potential_stop_time|
          #   puts "potential stop id 1: #{potential_stop_time.stop_id}"
          #   backtracked_to_this_stop ||= (potential_stop_time.stop_id == self.id) #self.id
          #   next unless backtracked_to_this_stop

          #   # find if potential_stop + trip_id is included in StopTimeUpdates
          #   found_earlier_stop_time_update = GTFS::Realtime::StopTimeUpdate.where(trip_update_id: trip_update.id, stop_id: potential_stop_time.stop_id).first
          #   puts "potential stop id 2: #{potential_stop_time.stop_id}"
          #   break if found_earlier_stop_time_update
          # end

          # festu = found_earlier_stop_time_update
          # if festu
          #   stop_time.set(GTFS::Realtime::StopTimeUpdate.new({
          #     arrival_time: stop_time.arrival_time + (festu.arrival_delay || 0),
          #     arrival_delay: festu.arrival_delay,
          #     departure_time: stop_time.departure_time + (festu.departure_delay || 0),
          #     departure_delay: festu.departure_delay
          #   }))
          # else
          #   # if we found no match, we must have passed this stop already, gah
          #   # TODO: better handling for departed buses
          #   stop_time.set(GTFS::Realtime::StopTimeUpdate.new({
          #     arrival_time: Time.now - 60,
          #     departure_time: Time.now - 60
          #   }))
          # end
        end

        stop_times
      end
    end
  end
end