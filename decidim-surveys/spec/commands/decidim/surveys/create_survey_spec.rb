# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe CreateSurvey do
        describe "call" do
          let(:component) { create(:component, manifest_name: "surveys") }
          let(:command) { described_class.new(component, form) }
          let(:invalid?) { false }
          let(:form) do
            double(
              invalid?: invalid?,
              title: { en: "title" },
              description: { en: "description" },
              tos: { en: "tos" }
            )
          end

          describe "when the survey is not saved" do
            before do
              # rubocop:disable RSpec/AnyInstance
              allow_any_instance_of(Survey).to receive(:save).and_return(false)
              # rubocop:enable RSpec/AnyInstance
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create a survey" do
              expect do
                command.call
              end.not_to change(Survey, :count)
            end
          end

          describe "when the form is invalid" do
            let(:invalid?) { true }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create a survey" do
              expect do
                command.call
              end.not_to change(Survey, :count)
            end
          end

          describe "when the survey is saved" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new survey with the same name as the component" do
              expect(Survey).to receive(:new).with(component:, questionnaire: kind_of(Decidim::Forms::Questionnaire)).and_call_original

              expect do
                command.call
              end.to change(Survey, :count).by(1)
            end

            it "creates a questionnaire with the attributes" do
              command.call

              survey = Survey.last
              expect(survey.questionnaire.title["en"]).to eq("title")
              expect(survey.questionnaire.description["en"]).to eq("description")
              expect(survey.questionnaire.tos["en"]).to eq("tos")
            end
          end
        end
      end
    end
  end
end
