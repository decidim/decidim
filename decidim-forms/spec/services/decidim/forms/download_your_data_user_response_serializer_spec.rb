# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe DownloadYourDataUserResponsesSerializer do
      include Decidim::TranslationsHelper

      subject do
        described_class.new(questionnaire.responses.first)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        context "when question is files" do
          let!(:question) { create(:questionnaire_question, questionnaire:, question_type: :files) }
          let!(:response) { create(:response, :with_attachments, questionnaire:, question:, user:) }

          it "includes the response id" do
            expect(serialized).to include(id: response.id)
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the response" do
            expect(serialized[:response]).to include_blob_urls(*response.attachments.map(&:file).map(&:blob))
          end
        end

        context "when question is short response" do
          let!(:question) { create(:questionnaire_question, questionnaire:) }
          let!(:response) { create(:response, questionnaire:, question:, user:) }

          it "includes the response id" do
            expect(serialized).to include(id: response.id)
          end

          it "includes the questionnaire information" do
            expect(serialized[:questionnaire]).to(
              include(id: questionnaire.id)
            )
            expect(serialized[:questionnaire]).to(
              include(title: translated_attribute(questionnaire.title))
            )
            expect(serialized[:questionnaire]).to(
              include(description: translated_attribute(questionnaire.description))
            )
            expect(serialized[:questionnaire]).to(
              include(tos: translated_attribute(questionnaire.tos))
            )
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(question.description))
            )
          end

          it "includes the response" do
            expect(serialized).to include(response: response.body)
          end
        end

        context "when question is multiple choice" do
          let!(:multichoice_question) { create(:questionnaire_question, questionnaire:, question_type: "multiple_option") }
          let!(:multichoice_response_options) { create_list(:response_option, 2, question: multichoice_question) }
          let!(:multichoice_response) do
            create(:response, questionnaire:, question: multichoice_question, user:, body: nil)
          end
          let!(:multichoice_response_choices) do
            multichoice_response_options.map do |response_option|
              create(:response_choice, response: multichoice_response, response_option:, body: response_option.body[I18n.locale.to_s])
            end
          end

          it "includes the response id" do
            expect(serialized).to include(id: multichoice_response.id)
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: multichoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(multichoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(multichoice_question.description))
            )
          end

          it "includes the responses" do
            expect(serialized).to include(response: multichoice_response_choices.map(&:body))
          end
        end

        context "when question is single choice" do
          let!(:singlechoice_question) { create(:questionnaire_question, questionnaire:, question_type: "single_option") }
          let!(:singlechoice_response_options) { create_list(:response_option, 2, question: singlechoice_question) }
          let!(:singlechoice_response) do
            create(:response, questionnaire:, question: singlechoice_question, user:, body: nil)
          end
          let!(:singlechoice_response_choice) do
            response_option = singlechoice_response_options.first
            create(:response_choice, response: singlechoice_response, response_option:, body: response_option.body[I18n.locale.to_s])
          end

          it "includes the response id" do
            expect(serialized).to include(id: singlechoice_response.id)
          end

          it "includes the question info" do
            expect(serialized[:question]).to(
              include(id: singlechoice_question.id)
            )
            expect(serialized[:question]).to(
              include(body: translated_attribute(singlechoice_question.body))
            )
            expect(serialized[:question]).to(
              include(description: translated_attribute(singlechoice_question.description))
            )
          end

          it "includes the responses" do
            expect(serialized).to include(response: [singlechoice_response_choice.body])
          end
        end
      end
    end
  end
end
