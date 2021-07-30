# frozen_string_literal: true

module Decidim
  module Forms
    class ExportQuestionnaireAnswersJob < ApplicationJob
      queue_as :exports

      def perform(user, title, answers)
        return if user&.email.blank?
        return if answers.blank?

        serializer = Decidim::Forms::UserAnswersSerializer
        export_data = Decidim::Exporters::FormPDF.new(answers, serializer).export

        ExportMailer.export(user, title, export_data).deliver_now
      end
    end
  end
end
