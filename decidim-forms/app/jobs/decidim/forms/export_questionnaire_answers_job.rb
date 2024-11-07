# frozen_string_literal: true

module Decidim
  module Forms
    class ExportQuestionnaireAnswersJob < ApplicationJob
      include Decidim::PrivateDownloadHelper

      queue_as :exports

      def perform(user, title, answers)
        return if user&.email.blank?
        return if answers.blank?

        serializer = Decidim::Forms::UserAnswersSerializer
        export_data = Decidim::Exporters::FormPDF.new(answers, serializer).export

        private_export = attach_archive(export_data, title, user)

        ExportMailer.export(user, title, private_export).deliver_later
      end
    end
  end
end
