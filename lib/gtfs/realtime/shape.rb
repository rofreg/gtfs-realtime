module GTFS
  class Realtime
    class Shape < GTFS::Realtime::Model
      dataset_module do
        def ordered_by_sequence
          order(:sequence)
        end
      end

      # order results by sequence by default
      set_dataset(self.ordered_by_sequence)
    end
  end
end