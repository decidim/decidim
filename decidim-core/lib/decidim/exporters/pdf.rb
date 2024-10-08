# frozen_string_literal: true

require "grover"

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
        html = controller.render_to_string(
          template:,
          layout:,
          locals:,
          assigns:
        )

        document = Grover.new(html, **grover_options).to_pdf

        ExportData.new(document, "pdf")
      end

      # may be overwritten if needed
      def grover_options
        {}
      end

      # implementing classes should return a valid ERB path here
      def template
        raise NotImplementedError
      end

      # implementing classes should return a valid ERB path here
      def layout
        raise NotImplementedError
      end

      # This method may be overwritten if the template needs more local variables
      def locals
        { collection: }
      end

      # This method may be overwritten if the template needs more instance variables
      def assigns
        { title: t("decidim.admin.exports.formats.PDF") }
      end

      protected

      def controller
        raise NotImplementedError
      end
    end
  end
end
