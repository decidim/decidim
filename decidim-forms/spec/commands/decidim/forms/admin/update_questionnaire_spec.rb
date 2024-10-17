# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    module Admin
      describe UpdateQuestionnaire do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
        let(:user) { create(:user, organization: current_organization) }
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
            }
          }
        end
        let(:form) do
          QuestionnaireForm.from_params(
            questionnaire: form_params
          ).with_context(
            current_organization:
          )
        end
        let(:command) { described_class.new(form, questionnaire, user) }

        describe "when the form is invalid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not update the questionnaire" do
            expect(questionnaire).not_to receive(:update!)
            command.call
          end
        end

        describe "when the form is valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the questionnaire" do
            command.call
            questionnaire.reload

            expect(questionnaire.description["en"]).to eq("<p>Content</p>")
            expect(questionnaire.title["en"]).to eq("Title")
            expect(questionnaire.tos["en"]).to eq("<p>TOS</p>")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("update", questionnaire, user)
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("update")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
