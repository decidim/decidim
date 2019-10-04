# frozen_string_literal: true

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
      def initialize(collection, serializer = Serializer)
        @collection = collection
        @serializer = serializer
      end

      # Public: Should generate an `ExportData` with the result of the export.
      # Responsibility of the subclass.
      def export
        raise NotImplementedError
      end

      private

      attr_reader :collection, :serializer
    end
  end
end
