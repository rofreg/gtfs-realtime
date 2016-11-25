$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gtfs/realtime"
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)
RSpec.configure do |config|
  STATIC_FEED_URL = "http://www.ripta.com/googledata/current/google_transit.zip"

  config.before(:each) do
    stub_request(:get, STATIC_FEED_URL).
      to_return(status: 200, body: File.open("./spec/fixtures/google_transit.zip"){|f| f.read}, headers: {})
  end
end