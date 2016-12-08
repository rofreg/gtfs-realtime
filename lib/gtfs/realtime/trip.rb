module GTFS
  class Realtime
    class Trip < GTFS::Realtime::Model
      belongs_to :route
      has_many :stop_times
      has_many :stops, through: :stop_times
      has_many :calendar_dates, primary_key: :service_id, foreign_key: :service_id
      has_many :shapes, primary_key: :shape_id, foreign_key: :id
      has_one :trip_update

      def active?(date)
        if calendar_dates.loaded?
          calendar_dates.find{|cd| cd.exception_type == GTFS::Realtime::CalendarDate::ADDED && cd.date == date}
        else
          calendar_dates.where(exception_type: GTFS::Realtime::CalendarDate::ADDED, date: date).any?
        end
      end
    end
  end
end
