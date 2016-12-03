module GTFS
  class Realtime
    class Shape < GTFS::Realtime::Model
      scope :ordered, -> { order(sequence: :ASC) }
    end
  end
end