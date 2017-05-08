module Decidim
  module Exporters
    # Abstract class providing the interface and partial implementation
    # of an exporter. See `Decidim::Exporters::JSON` and `Decidim::Exporters::CSV`
    # for a reference implementation.
    class Exporter
      # Public: Initializes an Exporter.
      #
      # collection - An Array with the collection to be exported.
      # serializer - A Serializer to be used during the export.
      def initialize(collection, serializer)
        @collection = collection
        @serializer = serializer
      end

      # Public: Should generate an `ExportData` with the result of the export.
      # Responsibility of the subclass.
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
