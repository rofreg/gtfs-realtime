module GTFS
  class Realtime
    module Nearby
      def nearby(latitude, longitude)
        # TODO: this math is terrible! It'll fail for various edge cases.
        # (e.g. close to the poles, overlapping to the prime meridian)
        # That said, it's an okay approximation within the United States.

        all.select do |stop|
          (stop.latitude - latitude).abs < 0.01 &&
            (stop.longitude - longitude).abs < 0.01
        end
      end
    end
  end
end