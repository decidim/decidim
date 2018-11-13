# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe UpdateQuestionnaire do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
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
            "questions" => {
              "0" => {
                "body" => {
                  "en" => "First question",
                  "ca" => "Primera pregunta",
                  "es" => "Primera pregunta"
                },
                "position" => "0",
                "question_type" => "short_answer",
                "answer_options" => {}
              },
              "1" => {
                "body" => {
                  "en" => "Second question",
                  "ca" => "Segona pregunta",
                  "es" => "Segunda pregunta"
                },
                "description" => { "en" => "Description" },
                "position" => "1",
                "mandatory" => "1",
                "question_type" => "long_answer",
                "answer_options" => {}
              },
              "2" => {
                "body" => {
                  "en" => "Third question",
                  "ca" => "Tercera pregunta",
                  "es" => "Tercera pregunta"
                },
                "position" => "2",
                "question_type" => "single_option",
                "answer_options" => {
                  "0" => {
                    "body" => {
                      "en" => "First answer",
                      "ca" => "Primera resposta",
                      "es" => "Primera respuesta"
                    },
                    "free_text" => "0"
                  },
                  "1" => {
                    "body" => {
                      "en" => "Second answer",
                      "ca" => "Segona resposta",
                      "es" => "Segunda respuesta"
                    }
                  }
                }
              },
              "3" => {
                "body" => {
                  "en" => "Fourth question",
                  "ca" => "Cuarta pregunta",
                  "es" => "Cuarta pregunta"
                },
                "position" => "3",
                "question_type" => "multiple_option",
                "max_choices" => "2",
                "answer_options" => {
                  "0" => {
                    "body" => {
                      "en" => "First answer",
                      "ca" => "Primera resposta",
                      "es" => "Primera respuesta"
                    },
                    "free_text" => "1"
                  },
                  "1" => {
                    "body" => {
                      "en" => "Second answer",
                      "ca" => "Segona resposta",
                      "es" => "Segunda respuesta"
                    }
                  }
                }
              }
            },
            "published_at" => published_at
          }
        end
        let(:form) do
          QuestionnaireForm.from_params(
            questionnaire: form_params
          ).with_context(
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, questionnaire) }

        describe "when the form is invalid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the questionnaire" do
            expect(questionnaire).not_to receive(:update!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the questionnaire" do
            command.call
            questionnaire.reload

            expect(questionnaire.description["en"]).to eq("<p>Content</p>")
            expect(questionnaire.questions.length).to eq(4)

            questionnaire.questions.each_with_index do |question, idx|
              expect(question.body["en"]).to eq(form_params["questions"][idx.to_s]["body"]["en"])
            end

            expect(questionnaire.questions[1]).to be_mandatory
            expect(questionnaire.questions[1].description["en"]).to eq(form_params["questions"]["1"]["description"]["en"])
            expect(questionnaire.questions[1].question_type).to eq("long_answer")
            expect(questionnaire.questions[2].answer_options[1]["body"]["en"]).to eq(form_params["questions"]["2"]["answer_options"]["1"]["body"]["en"])

            expect(questionnaire.questions[2].question_type).to eq("single_option")
            expect(questionnaire.questions[2].max_choices).to be_nil

            expect(questionnaire.questions[3].question_type).to eq("multiple_option")
            expect(questionnaire.questions[2].answer_options[0].free_text).to eq(false)
            expect(questionnaire.questions[2].max_choices).to be_nil

            expect(questionnaire.questions[3].question_type).to eq("multiple_option")
            expect(questionnaire.questions[3].answer_options[0].free_text).to eq(true)
            expect(questionnaire.questions[3].max_choices).to eq(2)
          end
        end

        describe "when the questionnaire has an existing question" do
          let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }

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
                    "id" => question.id,
                    "body" => question.body,
                    "position" => 0,
                    "question_type" => "short_answer",
                    "deleted" => "true"
                  }
                ]
              }
            end

            it "deletes the questionnaire question" do
              command.call
              questionnaire.reload

              expect(questionnaire.questions.length).to eq(0)
            end
          end
        end
      end
    end
  end
end
