# frozen_string_literal: true

require "hexapdf"

module Decidim
  module Exporters
    # Exports a PDF using the provided hash, given a collection and a
    # Serializer. This is an abstract class that should be inherited
    # to create PDF exporters, with each PDF exporter class setting
    # the desired template, layout and orientation.
    #
    class PDF < Exporter
      # Public: Exports a PDF version of the collection by rendering
      # the template into html and then converting it to PDF.
      #
      # Returns an ExportData instance.
      def export
        composer.styles(**styles)

        add_data!

        ExportData.new(composer.write_to_string, "pdf")
      end

      protected

      def layout = composer.document.layout

      def composer
        @composer ||= ::HexaPDF::Composer.new
      end

      def add_data!
        raise NotImplementedError
      end

      def font_family = "Times"

      def styles = {}
    end
  end
end
