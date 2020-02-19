# frozen_string_literal: true

require "wicked_pdf"

module Decidim
  module Exporters
    # TODO: Write doc
    # Exports any serialized object (Hash) into a readable PDF. It transforms
    # the columns [TODO!]
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: [TODO!]
    class PDF < Exporter
      # Public: Exports a PDF version of the collection using the
      # [TODO!].
      #
      # Returns an ExportData instance.
      def export(template:, layout:, orientation: "Portrait")
        html = controller.render_to_string(
          template: template,
          layout: layout,
          locals: { collection: collection }
        )

        document = WickedPdf.new.pdf_from_string(html, orientation: orientation)

        ExportData.new(document, "pdf")
      end

      def controller
        @controller ||= ActionController::Base.new
      end
    end
  end
end
