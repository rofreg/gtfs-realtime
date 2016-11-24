# TODO: remove this once my PR is accepted and a gtfs gem update is released
# (see https://github.com/nerdEd/gtfs/pull/33)
module GTFS
  module Model
    module ClassMethods
      def each(filename)
        headers = nil
        CSV.foreach(filename, :headers => true) do |row|
          headers ||= unprefixed_headers(row.headers)
          yield parse_model(headers, row.fields)
        end
      end

      def parse_model(headers, fields, options={})
        self.new(Hash[headers.zip(fields)])
      end

      def parse_models(data, options={})
        return [] if data.nil? || data.empty?

        models = []
        headers = nil
        CSV.parse(data, :headers => true) do |row|
          headers ||= unprefixed_headers(row.headers)
          model = parse_model(headers, row.fields)
          models << model if options[:strict] == false || model.valid?
        end
        models
      end

      def unprefixed_headers(headers)
        headers.collect{|h| h.gsub(/^#{prefix}/, '')}
      end
    end
  end
end