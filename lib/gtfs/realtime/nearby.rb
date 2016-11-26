module GTFS
  class Realtime
    module Nearby
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
      end

      module InstanceMethods
        def distance(latitude, longitude)
          Math::sqrt((latitude - self.latitude)**2 + (longitude - self.longitude)**2)
        end
      end

      module ClassMethods
        def nearby(latitude, longitude)
          # TODO: this math is terrible! It'll fail for various edge cases.
          # (e.g. close to the poles, overlapping to the prime meridian)
          # That said, it's an okay approximation away from the poles/meridian.

          all.select do |item|
            item.distance(latitude, longitude) < 0.01
          end
        end
      end
    end
  end
end