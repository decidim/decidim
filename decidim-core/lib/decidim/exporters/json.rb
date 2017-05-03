module Decidim
  module Exporters
    class JSON
      def initialize(serializer)
        @serializer = serializer
      end

      def export(collection)
        collection.map do |resource|
          @serializer.new(resource).serialize
        end.to_json
      end
    end
  end
end
