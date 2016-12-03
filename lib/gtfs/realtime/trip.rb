module GTFS
  class Realtime
    class Trip < GTFS::Realtime::Model
      belongs_to :route
      has_many :stop_times
      has_many :stops, through: :stop_times
      has_many :calendar_dates, primary_key: :service_id, foreign_key: :service_id
      has_many :shapes, primary_key: :shape_id, foreign_key: :id

      def active?(date)
        calendar_dates.where(exception_type: GTFS::Realtime::CalendarDate::ADDED, date: date).any?
      end
    end
  end
end
