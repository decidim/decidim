# frozen_string_literal: true

module Decidim
  module Exporters
    # Holds the result of an export.
    class ExportData
      attr_reader :extension

      # Initializes an `ExportData` with the RAW data and the extension.
      def initialize(data, extension)
        @data = data
        @extension = extension
      end

      # Gives back the raw data of the export.
      #
      # Returns a String with the result of the export.
      def read
        @data
      end
    end
  end
end
