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

      # Generates a filename based on the export creation date.
      #
      # prefix - A string value for the filename prefix. (default: 'export')
      # options - An optional hash of options
      #         * extension - Whether the filename should include the extension or not.
      #
      # Returns a String with the filename of the export.
      def filename(prefix = "export", options = {})
        options[:extension] = options[:extension].nil? ? true : options[:extension]
        result = "#{prefix}-#{I18n.l(Time.zone.today, format: :default)}-#{Time.now.seconds_since_midnight.to_i}"
        result += ".#{extension}" if options[:extension]
        result
      end
    end
  end
end
