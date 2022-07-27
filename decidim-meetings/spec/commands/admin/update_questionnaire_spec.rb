# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe UpdateQuestionnaire do
        let(:current_organization) { create(:organization) }
        let(:user) { create :user, organization: current_organization }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
        let(:meeting) { create :meeting, component: current_component }
        let(:form_params) do
          {
            "questions" => {
              "0" => {
                "body" => {
                  "en" => "First question",
                  "ca" => "Primera pregunta",
                  "es" => "Primera pregunta"
                },
                "position" => "0",
                "question_type" => "single_option",
                "answer_options" => {
                  "0" => {
                    "body" => {
                      "en" => "First answer",
                      "ca" => "Primera resposta",
                      "es" => "Primera respuesta"
                    }
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
              "1" => {
                "body" => {
                  "en" => "Second question",
                  "ca" => "Segona pregunta",
                  "es" => "Segunda pregunta"
                },
                "position" => "1",
                "question_type" => "multiple_option",
                "max_choices" => "2",
                "answer_options" => {
                  "0" => {
                    "body" => {
                      "en" => "First answer",
                      "ca" => "Primera resposta",
                      "es" => "Primera respuesta"
                    }
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
            }
          }
        end
        let(:form) do
          QuestionnaireForm.from_params(
            questionnaire: form_params
          ).with_context(
            current_organization:,
            current_user: user
          )
        end
        let(:command) { described_class.new(form, questionnaire) }

        context "with a persisted poll and questionnaire" do
          let(:poll) { create(:poll, meeting:) }
          let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }

          describe "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
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

              expect(questionnaire.questions[0].question_type).to eq("single_option")
              expect(questionnaire.questions[0].max_choices).to be_nil
              expect(questionnaire.questions[0].answer_options[1]["body"]["en"]).to eq(form_params["questions"]["0"]["answer_options"]["1"]["body"]["en"])

              expect(questionnaire.questions[1].question_type).to eq("multiple_option")
              expect(questionnaire.questions[1].max_choices).to eq(2)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with("update", Decidim::Meetings::Questionnaire, user, { meeting: })
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.action).to eq("update")
              expect(action_log.version).to be_present
            end
          end

          describe "when the questionnaire has an existing question" do
            let!(:question) { create(:meetings_poll_question, questionnaire:) }

            context "and the question should be removed" do
              let(:form_params) do
                {
                  "questions" => [
                    {
                      "id" => question.id,
                      "body" => question.body,
                      "position" => 0,
                      "question_type" => "single_option",
                      "deleted" => "true",
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

        context "with a new poll and questionnaire" do
          let(:poll) { build(:poll) }
          let(:questionnaire) { build(:meetings_poll_questionnaire, questionnaire_for: poll) }

          describe "when the form is invalid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
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

            it "persists the poll" do
              command.call
              poll.reload

              expect(poll).not_to be_new_record
            end

            it "persists the questionnaire" do
              command.call
              questionnaire.reload

              expect(questionnaire).not_to be_new_record
            end

            it "updates the questionnaire" do
              command.call
              questionnaire.reload

              expect(questionnaire.questions[0].question_type).to eq("single_option")
              expect(questionnaire.questions[0].max_choices).to be_nil
              expect(questionnaire.questions[0].answer_options[1]["body"]["en"]).to eq(form_params["questions"]["0"]["answer_options"]["1"]["body"]["en"])

              expect(questionnaire.questions[1].question_type).to eq("multiple_option")
              expect(questionnaire.questions[1].max_choices).to eq(2)
            end
          end

          describe "when the questionnaire has an existing question" do
            let!(:question) { create(:meetings_poll_question, questionnaire:) }

            context "and the question should be removed" do
              let(:form_params) do
                {
                  "questions" => [
                    {
                      "id" => question.id,
                      "body" => question.body,
                      "position" => 0,
                      "question_type" => "single_option",
                      "deleted" => "true",
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
end
