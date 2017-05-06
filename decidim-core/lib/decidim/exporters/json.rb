require "json"

module Decidim
  module Exporters
    class JSON < Exporter
      def export
        data = ::JSON.pretty_generate(@collection.map do |resource|
          @serializer.new(resource).serialize
        end)

        ExportData.new(data, "json")
      end
    end
  end
end
