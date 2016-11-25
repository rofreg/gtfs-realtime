module GTFS
  class Realtime
    class Trip < GTFS::Realtime::Model
      many_to_one :route
      many_to_many :stops, join_table: :gtfs_realtime_stop_times

      # TODO: find shapes by shape_id
    end
  end
end
