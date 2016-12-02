module GTFS
  class Realtime
    class Trip < GTFS::Realtime::Model
      belongs_to :route
      has_many :stop_times
      has_many :stops, through: :stop_times
      has_many :calendar_dates, primary_key: :service_id, foreign_key: :service_id
      has_many :shapes, primary_key: :shape_id, foreign_key: :id

      def active?(date)
        # can't use .where chaining b/c Sequel is weird
        calendar_dates.find{|cd| cd.exception_type == GTFS::Realtime::CalendarDate::ADDED && cd.date == date}
      end
    end
  end
end
