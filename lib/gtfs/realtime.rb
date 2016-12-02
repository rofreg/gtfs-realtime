require "google/transit/gtfs-realtime.pb"
require "gtfs"
require "active_record"

require "gtfs/realtime/configuration"
require "gtfs/realtime/model"

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

        # we must have a database by this point, so initialize the other models
        require 'gtfs/realtime/bootstrap'

        run_migrations
        load_static_feed!
        refresh_realtime_feed!
      end

      private

      def run_migrations
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        # ActiveRecord::Migration.verbose = true
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Migrator.migrate(File.expand_path("../realtime/migrations", __FILE__))
      end
    end
  end
end
