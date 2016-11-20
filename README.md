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

TODO: add more instructions here. Basic functionality currently works like this:

```
  gtfs = GTFS::Realtime.new("http://www.ripta.com/googledata/current/google_transit.zip", "http://realtime.ripta.com")
  nearby = gtfs.nearby(41.834521, -71.396906)
  upcoming_bus = nearby[0].trip_updates.first
  trip_info = upcoming_bus.trip_info
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rofreg/gtfs-realtime. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
