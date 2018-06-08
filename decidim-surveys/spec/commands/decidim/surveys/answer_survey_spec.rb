# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe AnswerSurvey do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: current_organization) }
      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:component) { create(:component, manifest_name: "surveys", participatory_space: participatory_process) }
      let(:survey) { create(:survey, component: component) }
      let(:survey_question_1) { create(:survey_question, survey: survey) }
      let(:survey_question_2) { create(:survey_question, survey: survey) }
      let(:survey_question_3) { create(:survey_question, survey: survey) }
      let(:answer_options) { create_list(:survey_answer_option, 5, question: survey_question_2) }
      let(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
      let(:form_params) do
        {
          "survey_answers" => [
            {
              "body" => "This is my first answer",
              "question_id" => survey_question_1.id
            },
            {
              "choices" => [
                { "answer_option_id" => answer_option_ids[0], "body" => "My" },
                { "answer_option_id" => answer_option_ids[1], "body" => "second" },
                { "answer_option_id" => answer_option_ids[2], "body" => "answer" }
              ],
              "question_id" => survey_question_2.id
            },
            {
              "choices" => [
                { "answer_option_id" => answer_option_ids[3], "body" => "Third", "position" => 0 },
                { "answer_option_id" => answer_option_ids[4], "body" => "answer", "position" => 1 }
              ],
              "question_id" => survey_question_3.id
            }
          ],
          "tos_agreement" => "1"
        }
      end
      let(:form) do
        SurveyForm.from_params(
          form_params
        ).with_context(
          current_organization: current_organization,
          current_component: component
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
          end.not_to change(SurveyAnswer, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a survey answer for each question answered" do
          expect do
            command.call
          end.to change(SurveyAnswer, :count).by(3)
          expect(SurveyAnswer.all.map(&:survey)).to eq([survey, survey, survey])
        end

        it "creates answers with the correct information" do
          command.call

          expect(SurveyAnswer.first.body).to eq("This is my first answer")
          expect(SurveyAnswer.second.choices.pluck(:body)).to eq(%w(My second answer))
          expect(SurveyAnswer.third.choices.pluck(:body, :position)).to eq([["Third", 0], ["answer", 1]])
        end
      end
    end
  end
end
