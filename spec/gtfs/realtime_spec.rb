require "spec_helper"

describe GTFS::Realtime do
  it "has a version number" do
    expect(GTFS::Realtime::VERSION).not_to be nil
  end

  it "loads data with the gtfs gem" do
    expect(GTFS::Source).to receive(:build).with(STATIC_FEED_URL)

    GTFS::Realtime.configure do |config|
      config.static_feed = STATIC_FEED_URL
    end
  end

  it "loads static GTFS data into a database" do
    expect(GTFS::Realtime::Route).to receive(:multi_insert)

    GTFS::Realtime.configure do |config|
      config.static_feed = STATIC_FEED_URL
    end
  end
end
