require "google/transit/gtfs-realtime.pb"
require "gtfs"
require "active_record"
require "bulk_insert"
require "gtfs/gtfs_gem_patch"

require "gtfs/realtime/configuration"
require "gtfs/realtime/model"
require "gtfs/realtime/calendar_date"
require "gtfs/realtime/route"
require "gtfs/realtime/service_alert"
require "gtfs/realtime/shape"
require "gtfs/realtime/stop"
require "gtfs/realtime/stop_time"
require "gtfs/realtime/stop_time_update"
require "gtfs/realtime/trip"
require "gtfs/realtime/trip_update"
require "gtfs/realtime/vehicle_position"
require "gtfs/realtime/version"

module GTFS
  class Realtime
    # This is a singleton object, so everything will be on the class level
    class << self
      attr_accessor :configuration

      def configuration
        @configuration ||= GTFS::Realtime::Configuration.new
      end

      def configure
        yield(configuration)

        run_migrations
        load_static_feed!
        refresh_realtime_feed!
      end

      def load_static_feed!(force: false)
        return if !force && GTFS::Realtime::Route.count > 0

        static_data = GTFS::Source.build(@configuration.static_feed)
        return unless static_data

        GTFS::Realtime::Model.transaction do
          GTFS::Realtime::CalendarDate.delete_all
          GTFS::Realtime::CalendarDate.bulk_insert(values:
            static_data.calendar_dates.collect do |calendar_date|
              {
                service_id: calendar_date.service_id.strip,
                date: Date.strptime(calendar_date.date, "%Y%m%d"),
                exception_type: calendar_date.exception_type
              }
            end
          )

          GTFS::Realtime::Route.delete_all
          GTFS::Realtime::Route.bulk_insert(:id, :short_name, :long_name, :url, values:
            static_data.routes.collect do |route|
              {
                id: route.id.strip,
                short_name: route.short_name,
                long_name: route.long_name,
                url: route.url
              }
            end
          )

          GTFS::Realtime::Shape.delete_all
          GTFS::Realtime::Shape.bulk_insert(:id, :sequence, :latitude, :longitude, values:
            static_data.shapes.collect do |shape|
              {
                id: shape.id.strip,
                sequence: shape.pt_sequence,
                latitude: shape.pt_lat.to_f,
                longitude: shape.pt_lon.to_f
              }
            end
          )

          GTFS::Realtime::Stop.delete_all
          GTFS::Realtime::Stop.bulk_insert(:id, :name, :latitude, :longitude, values:
            static_data.stops.collect do |stop|
              {
                id: stop.id.strip,
                name: stop.name.strip,
                latitude: stop.lat.to_f,
                longitude: stop.lon.to_f
              }
            end
          )

          GTFS::Realtime::StopTime.delete_all
          GTFS::Realtime::StopTime.bulk_insert(values:
            static_data.stop_times.collect do |stop_time|
              {
                stop_id: stop_time.stop_id.strip,
                trip_id: stop_time.trip_id.strip,
                arrival_time: stop_time.arrival_time,
                departure_time: stop_time.departure_time,
                stop_sequence: stop_time.stop_sequence.to_i
              }
            end
          )

          GTFS::Realtime::Trip.delete_all
          GTFS::Realtime::Trip.bulk_insert(:id, :headsign, :route_id, :service_id, :shape_id, :direction_id, values:
            static_data.trips.collect do |trip|
              {
                id: trip.id.strip,
                headsign: trip.headsign.strip,
                route_id: trip.route_id.strip,
                service_id: trip.service_id.strip,
                shape_id: trip.shape_id.strip,
                direction_id: trip.direction_id
              }
            end
          )
        end
      end

      def refresh_realtime_feed!
        trip_updates = get_entities(@configuration.trip_updates_feed)
        vehicle_positions = get_entities(@configuration.vehicle_positions_feed)
        service_alerts = get_entities(@configuration.service_alerts_feed)

        GTFS::Realtime::Model.transaction do
          GTFS::Realtime::TripUpdate.delete_all
          GTFS::Realtime::TripUpdate.bulk_insert(:id, :trip_id, :route_id, values:
            trip_updates.collect do |trip_update|
              {
                id: trip_update.id.strip,
                trip_id: trip_update.trip_update.trip.trip_id.strip,
                route_id: trip_update.trip_update.trip.route_id.strip
              }
            end
          )

          GTFS::Realtime::StopTimeUpdate.delete_all
          GTFS::Realtime::StopTimeUpdate.bulk_insert(values:
            trip_updates.collect do |trip_update|
              trip_update.trip_update.stop_time_update.collect do |stop_time_update|
                {
                  trip_update_id: trip_update.id.strip,
                  stop_id: stop_time_update.stop_id.strip,
                  arrival_delay: stop_time_update.arrival&.delay,
                  arrival_time: (stop_time_update.arrival&.time&.> 0) ? Time.at(stop_time_update.arrival.time) : nil,
                  departure_delay: stop_time_update.departure&.delay,
                  departure_time: (stop_time_update.departure&.time&.> 0) ? Time.at(stop_time_update.departure.time) : nil,
                }
              end
            end.flatten
          )

          GTFS::Realtime::VehiclePosition.delete_all
          GTFS::Realtime::VehiclePosition.bulk_insert(values:
            vehicle_positions.collect do |vehicle|
              {
                trip_id: vehicle.vehicle.trip.trip_id.strip,
                stop_id: vehicle.vehicle.stop_id.strip,
                latitude: vehicle.vehicle.position.latitude.to_f,
                longitude: vehicle.vehicle.position.longitude.to_f,
                bearing: vehicle.vehicle.position.bearing.to_f,
                timestamp: Time.at(vehicle.vehicle.timestamp)
              }
            end
          )

          GTFS::Realtime::ServiceAlert.delete_all
          GTFS::Realtime::ServiceAlert.bulk_insert(values:
            service_alerts.collect do |service_alert|
              {
                stop_id: service_alert.alert.informed_entity.first.stop_id.strip,
                header_text: service_alert.alert.header_text.translation.first.text,
                description_text: service_alert.alert.description_text.translation.first.text,
                start_time: Time.at(service_alert.alert.active_period.first.start),
                end_time: Time.at(service_alert.alert.active_period.first.end)
              }
            end
          )
        end
      end

      private

      def get_entities(path)
        return [] if path.nil?

        if File.exists?(path)
          data = File.open(path, 'r'){|f| f.read}
        else
          data = Net::HTTP.get(URI.parse(path))
        end
        feed = Transit_realtime::FeedMessage.decode(data)
        feed.entity   # array of entities
      end


      def run_migrations
        ActiveRecord::Migration.verbose = false

        if ActiveRecord.version.release() < Gem::Version.new('5.2.0')
          ActiveRecord::Migrator.migrate(File.expand_path("../realtime/migrations", __FILE__))
        else
          ActiveRecord::MigrationContext.new(File.expand_path("../realtime/migrations", __FILE__)).migrate
        end
      end
    end
  end
end
