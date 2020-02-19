# frozen_string_literal: true

require "wicked_pdf"

module Decidim
  module Exporters
    # TODO: Write doc!
    # Exports any serialized object (Hash) into a readable PDF. It transforms
    # the columns [TODO!]
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: [TODO!]
    class SurveyPDF < PDF
      # Public: Exports a PDF version of the collection using the
      # [TODO!].
      #
      # Returns an ExportData instance.
      def export(template:, layout:, orientation: "Portrait")
        super(template: template, layout: layout, orientation: orientation)
      end

      def controller
        super.class_eval do
          helper Decidim::TranslationsHelper
          helper Decidim::Forms::Admin::QuestionnaireAnswersHelper
        end
        super
      end
    end
  end
end
