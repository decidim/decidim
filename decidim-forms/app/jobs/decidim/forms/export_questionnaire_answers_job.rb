# frozen_string_literal: true

module Decidim
  module Forms
    class ExportQuestionnaireAnswersJob < ApplicationJob
      include Decidim::PrivateDownloadHelper

      queue_as :exports

      def perform(user, file_name, answers, export_type = nil)
        return if user&.email.blank?
        return if answers.blank?

        serializer = Decidim::Forms::UserAnswersSerializer
        export_data = Decidim::Exporters::FormPDF.new(answers, serializer).export

        private_export = attach_archive(export_data, file_name, user, export_type)

        ExportMailer.export(user, private_export).deliver_later
      end
    end
  end
end
