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
      def controller
        super.class_eval do
          helper Decidim::TranslationsHelper
          helper Decidim::Forms::Admin::QuestionnaireAnswersHelper
        end
        super
      end

      def template
        "decidim/forms/admin/questionnaires/answers/export/pdf.html.erb"
      end

      def layout
        "decidim/forms/admin/questionnaires/questionnaire_answers.html.erb"
      end

      def orientation
        "Portrait"
      end
    end
  end
end
