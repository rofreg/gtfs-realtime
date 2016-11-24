# gtfs-realtime

gfts-realtime is a gem to interact with realtime transit data presented in the [GTFS Realtime format](https://developers.google.com/transit/gtfs-realtime/). It was built in order to interact with the RIPTA realtime data API for the public bus system in Providence, RI.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gtfs-realtime'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gtfs-realtime

## Usage

Basic functionality currently works like this:

```
require 'gtfs-realtime'

GTFS::Realtime.configure do |config|
  config.static_feed = "http://www.ripta.com/googledata/current/google_transit.zip"   # File path or URL
  config.trip_updates_feed = "http://realtime.ripta.com:81/api/tripupdates"
  config.vehicle_positions_feed = "http://realtime.ripta.com:81/api/vehiclepositions"
  config.service_alerts_feed = "http://realtime.ripta.com:81/api/servicealerts"
  config.database_path = "sqlite://database.db"    # leave unset to use an in-memory database
end

# After calling 'configure', the gem loads all relevant GTFS info into a database.
# This may take some time (up to a minute) depending on the size of the input data.
# By default, gtfs-realtime uses an in-memory database, which requires reloading all
# data from scratch on each launch. If you'd like to use a persistent database instead,
# set 'config.database_path' above, and include a scheme/protocol path for the DB type
# that you would like to use. gtfs-realtime will generate the relevant tables.

@nearby = GTFS::Realtime::Stop.nearby(41.834521, -71.396906)
stop = @nearby.first
upcoming_bus = stop.stop_time_updates.first
trip_info = upcoming_bus.trip
route_info = upcoming_bus.route
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rofreg/gtfs-realtime. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
