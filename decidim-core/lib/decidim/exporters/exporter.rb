module Decidim
  module Exporters
    class Exporter
      def initialize(collection, serializer)
        @collection = collection
        @serializer = serializer
      end

      def export
        raise NotImplementedError
      end

      private

      def collection
        @collection
      end

      def serializer
        @serializer
      end
    end
  end
end
