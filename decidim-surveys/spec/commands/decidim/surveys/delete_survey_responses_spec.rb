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
        end
      end
    end
  end
end
