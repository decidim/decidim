# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe DeleteSurveyResponses, type: :command do
        let(:survey) { create(:survey, published_at: Time.current) }
        let(:current_user) { create(:user, :admin, :confirmed, organization: survey.component.organization) }
        let(:command) { described_class.new(survey, current_user) }

        let!(:responses) do
          survey.questionnaire.questions.map do |question|
            create(:response, questionnaire: survey.questionnaire, question:, user: current_user)
          end
        end

        describe "call" do
          context "when the survey is not valid" do
            before do
              allow(survey).to receive(:questionnaire).and_return(nil)
            end

            it "returns broadcast invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end

          it "broadcasts ok" do
            expect(command).to broadcast(:ok)
          end

          it "deletes all the survey responses" do
            expect { command.call }.to change(Decidim::Forms::Response, :count).by(-responses.size)
            expect(survey.questionnaire.reload.responses).to be_empty
          end

          it "traces the action" do
            expect(Decidim.traceability).to receive(:perform_action!).with(
              "delete_all_responses",
              survey.questionnaire,
              current_user
            ).and_call_original

            command.call
          end

          context "when responses have choices" do
            let(:question_with_options) { survey.questionnaire.questions.find_by(question_type: :single_option) }
            let!(:choice_response) do
              create(:response, questionnaire: survey.questionnaire, question: question_with_options, user: current_user)
            end
            let!(:choice) do
              create(:response_choice,
                     response: choice_response,
                     response_option: question_with_options.response_options.first,
                     matrix_row: nil)
            end

            it "destroys the associated response choices" do
              expect { command.call }.to change(Decidim::Forms::ResponseChoice, :count).by(-1)
              expect { choice.reload }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context "when responses have attachments" do
            let!(:response_with_attachments) do
              create(:response, :with_attachments, questionnaire: survey.questionnaire, question: survey.questionnaire.questions.first, user: current_user)
            end

            it "destroys the associated attachments" do
              expect { command.call }.to change(Decidim::Attachment, :count).by(-2)
            end
          end
        end
      end
    end
  end
end
