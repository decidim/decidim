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
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

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

      delegate :document, to: :composer
      delegate :layout, to: :document

      def font
        @font ||= load_font("source-sans-pro-v21-cyrillic_cyrillic-ext_greek_greek-ext_latin_latin-ext_vietnamese-regular.ttf")
      end

      def bold_font
        @bold_font ||= load_font("source-sans-pro-v21-cyrillic_cyrillic-ext_greek_greek-ext_latin_latin-ext_vietnamese-700.ttf")
      end

      def load_font(path)
        document.fonts.add(Decidim::Core::Engine.root.join("app/packs/fonts/decidim/").join(path))
      end

      def composer
        @composer ||= ::HexaPDF::Composer.new(page_size:, page_orientation:)
      end

      def page_size = :A4

      def page_orientation = :portrait

      def add_data!
        raise NotImplementedError
      end

      def styles = {}
    end
  end
end
