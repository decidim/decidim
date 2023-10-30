# frozen_string_literal: true

require "spec_helper"
require "zip"

module Decidim
  module Surveys
    describe SurveyConfirmationMailer do
      let(:user) { create(:user, name: "Sarah Connor", organization:) }
      let!(:organization) { create(:organization) }
      let(:survey) { create(:survey) }
      let(:component) { survey.component }
      let(:questionnaire) { survey.questionnaire }
      let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
      let!(:answers) { questions.map { |q| create(:answer, question: q, questionnaire:) } }

      describe "confirmation" do
        let(:serializer) { Decidim::Forms::UserAnswersSerializer }
        let(:export_data) { Decidim::Exporters::FormPDF.new(answers, serializer) }
        let(:mail) { described_class.confirmation(user, questionnaire, [answers]) }

        it "sets a subject" do
          expect(mail.subject).to include(I18n.t("decidim.surveys.survey_confirmation_mailer.confirmation.subject", questionnaire_title: translated(questionnaire.title)))
        end

        it "set the attachment" do
          expect(mail.attachments.length).to eq(1)

          attachment = mail.attachments.first
          expect(attachment.filename).to include("Survey answers")
        end
      end
    end
  end
end
