module GTFS
  class Realtime
    class Model < ActiveRecord::Base
      self.abstract_class = true
      self.table_name_prefix = "gtfs_realtime_"
    end
  end
end
