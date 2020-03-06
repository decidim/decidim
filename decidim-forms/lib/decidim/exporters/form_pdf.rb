# frozen_string_literal: true

require "wicked_pdf"

module Decidim
  module Exporters
    # Inherits from abstract PDF exporter. This class is used to set
    # the parameters used to create a PDF when exporting Survey Answers.
    #
    class FormPDF < PDF
      # i18n-tasks-use t('decidim.admin.exports.formats.FormPDF')

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
    end
  end
end
