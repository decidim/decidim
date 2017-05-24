# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe AnswerSurvey, :db do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:feature) { create(:feature, manifest_name: "surveys", participatory_process: participatory_process) }
      let(:survey) { create(:survey, feature: feature) }
      let(:survey_question_1) { create(:survey_question, survey: survey) }
      let(:survey_question_2) { create(:survey_question, survey: survey) }
      let(:form_params) do
        {
          "answers" => [
            {
              "body" => "This is my first answer",
              "question_id" => survey_question_1.id
            },
            {
              "body" => "This is my first answer",
              "question_id" => survey_question_2.id
            }
          ]
        }
      end
      let(:form) do
        SurveyForm.from_params(
          form_params
        ).with_context(
          current_organization: current_organization,
          current_feature: feature
        )
      end
      let(:command) { described_class.new(form, current_user, survey) }

      describe "when the form is invalid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create survey answers" do
          expect do
            command.call
          end.not_to change { SurveyAnswer.count }
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a survey answer for each question answered" do
          expect do
            command.call
          end.to change { SurveyAnswer.count }.by(2)
          last_answer = SurveyAnswer.last
          expect(last_answer.survey).to eq(survey)
        end
      end
    end
  end
end
