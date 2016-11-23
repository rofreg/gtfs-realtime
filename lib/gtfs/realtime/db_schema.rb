# This script sets up an in-memory DB so that it can be used by this gem.
# It also extends Sequel::Model so that Sequel may be used independently by
# the parent project if desired.
db = Sequel.sqlite(ENV["GTFS_DATABASE_PATH"])

# Set up all database tables
db.create_table? :routes do
  String :id, primary_key: true
  String :short_name
  String :long_name
  String :url

  index :id
end

db.create_table? :stops do
  String :id, primary_key: true
  String :name
  Double :latitude
  Double :longitude

  index :id
end

db.create_table? :stop_times do
  String :trip_id
  String :stop_id
  String :arrival_time
  String :departure_time
  Integer :stop_sequence

  index :trip_id
  index :stop_id
end

db.create_table? :trips do
  String :id, primary_key: true
  String :headsign
  String :route_id
  String :service_id
  String :shape_id

  index :id
  index :route_id
end

db.create_table? :trip_updates do
  String :id, primary_key: true
  String :trip_id
  String :route_id

  index :id
end

db.create_table? :stop_time_updates do
  String :trip_update_id
  String :stop_id
  Integer :arrival_delay
  Time :arrival_time
  Integer :departure_delay
  Time :departure_time

  index :trip_update_id
  index :stop_id
end

# Set up all gtfs-realtime models to use this database
GTFS::Realtime::Model = Class.new(Sequel::Model)
GTFS::Realtime::Model.db = db
GTFS::Realtime::Model.plugin :many_through_many