# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyConfirmationMailer < ApplicationMailer
      include TranslatableAttributes
      helper Decidim::SanitizeHelper

      def confirmation(user, questionnaire, component, answers)
        @user = user
        @organization = user.organization
        @questionnaire_title = translated_attribute(questionnaire.title)
        @participatory_space_title = translated_attribute(component.participatory_space.title)

        return if answers.blank?

        add_file_with_answers(answers)

        mail(to: "#{@user.name} <#{@user.email}>", subject: t(".subject", questionnaire_title: @questionnaire_title))
      end

      private

      def add_file_with_answers(answers)
        export_name = t("decidim.surveys.survey_confirmation_mailer.export_name")
        serializer = Decidim::Forms::UserAnswersSerializer

        export_data = Decidim::Exporters::FormPDF.new(answers, serializer).export

        filename = export_data.filename(export_name)
        filename_without_extension = export_data.filename(export_name, extension: false)

        attachments["#{filename_without_extension}.zip"] = FileZipper.new(filename, export_data.read).zip
      end
    end
  end
end
