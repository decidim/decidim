# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe UpdateSurvey do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:feature) { create(:feature, manifest_name: "surveys", participatory_space: participatory_process) }
        let(:survey) { create(:survey, feature: feature) }
        let(:published_at) { nil }
        let(:form_params) do
          {
            "title" => {
              "en" => "Title",
              "ca" => "Title",
              "es" => "Title"
            },
            "tos" => {
              "en" => "<p>TOS</p>",
              "ca" => "<p>TOS</p>",
              "es" => "<p>TOS</p>"
            },
            "description" => {
              "en" => "<p>Content</p>",
              "ca" => "<p>Contingut</p>",
              "es" => "<p>Contenido</p>"
            },
            "questions" => [
              {
                "body" => {
                  "en" => "First question",
                  "ca" => "Primera pregunta",
                  "es" => "Primera pregunta"
                },
                "position" => "0",
                "question_type" => "short_answer",
                "answer_options" => []
              },
              {
                "body" => {
                  "en" => "Second question",
                  "ca" => "Segona pregunta",
                  "es" => "Segunda pregunta"
                },
                "position" => "1",
                "mandatory" => "1",
                "question_type" => "long_answer",
                "answer_options" => []
              },
              {
                "body" => {
                  "en" => "Third question",
                  "ca" => "Tercera pregunta",
                  "es" => "Tercera pregunta"
                },
                "position" => "2",
                "question_type" => "single_option",
                "answer_options" => [
                  {
                    "body" => {
                      "en" => "First answer",
                      "ca" => "Primera resposta",
                      "es" => "Primera respuesta"
                    }
                  },
                  {
                    "body" => {
                      "en" => "Second answer",
                      "ca" => "Segona resposta",
                      "es" => "Segunda respuesta"
                    }
                  }
                ]
              }
            ],
            "published_at" => published_at
          }
        end
        let(:form) do
          SurveyForm.from_params(
            form_params
          ).with_context(
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, survey) }

        describe "when the form is invalid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the survey" do
            expect(survey).not_to receive(:update_attributes!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the survey" do
            command.call
            survey.reload

            expect(survey.description["en"]).to eq("<p>Content</p>")
            expect(survey.questions.length).to eq(3)

            survey.questions.each_with_index do |question, idx|
              expect(question.body["en"]).to eq(form_params["questions"][idx]["body"]["en"])
            end

            expect(survey.questions[1]).to be_mandatory
            expect(survey.questions[1].question_type).to eq("long_answer")
            expect(survey.questions[2].answer_options[1]["body"]["en"]).to eq(form_params["questions"][2]["answer_options"][1]["body"]["en"])
          end
        end

        describe "when the survey has an existing question" do
          let!(:survey_question) { create(:survey_question, survey: survey) }

          context "and the question should be removed" do
            let(:form_params) do
              {
                "title" => {
                  "en" => "Title",
                  "ca" => "Title",
                  "es" => "Title"
                },
                "description" => {
                  "en" => "<p>Content</p>",
                  "ca" => "<p>Contingut</p>",
                  "es" => "<p>Contenido</p>"
                },
                "tos" => {
                  "en" => "<p>TOS</p>",
                  "ca" => "<p>TOS</p>",
                  "es" => "<p>TOS</p>"
                },
                "questions" => [
                  {
                    "id" => survey_question.id,
                    "body" => survey_question.body,
                    "position" => 0,
                    "question_type" => "short_answer",
                    "deleted" => "true"
                  }
                ]
              }
            end

            it "deletes the survey question" do
              command.call
              survey.reload

              expect(survey.questions.length).to eq(0)
            end
          end
        end
      end
    end
  end
end
