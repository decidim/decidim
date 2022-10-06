# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe CreateSurvey do
      describe "call" do
        let(:component) { create(:component, manifest_name: "surveys") }
        let(:command) { described_class.new(component) }

        describe "when the survey is not saved" do
          before do
            # rubocop:disable RSpec/AnyInstance
            allow_any_instance_of(Survey).to receive(:save).and_return(false)
            # rubocop:enable RSpec/AnyInstance
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a survey" do
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
        end
      end
    end
  end
end
