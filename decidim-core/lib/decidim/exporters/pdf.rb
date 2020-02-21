# frozen_string_literal: true

require "wicked_pdf"

module Decidim
  module Exporters
    # Exports a PDF using the provided hash, given a collection and a
    # Serializer. This is an abstract class that should be inherited
    # to create PDF exporters, with each pdf exporter class setting
    # the desired template, layout and orientation.
    #
    class PDF < Exporter
      # Public: Exports a PDF version of the collection by rendering
      # the template into html and then converting it to PDF.
      #
      # Returns an ExportData instance.
      def export
        html = controller.render_to_string(
          template: template,
          layout: layout,
          locals: { collection: collection }
        )

        document = WickedPdf.new.pdf_from_string(html, orientation: orientation)

        ExportData.new(document, "pdf")
      end

      protected

      def controller
        @controller ||= ActionController::Base.new
      end

      def template
        raise NotImplementedError
      end

      def layout
        raise NotImplementedError
      end

      def orientation
        raise NotImplementedError
      end
    end
  end
end
