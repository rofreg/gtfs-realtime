require "google/transit/gtfs-realtime.pb"
require "gtfs"
require "sequel"

require "gtfs/realtime/configuration"

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

        load_static_feed!
        refresh_realtime_feed!
      end
    end
  end
end
