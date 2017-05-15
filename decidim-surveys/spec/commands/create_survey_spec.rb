# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe CreateSurvey, :db do
      describe "call" do
        let(:feature) { create(:feature, manifest_name: "surveys") }
        let(:command) { described_class.new(feature) }

        describe "when the survey is not saved" do
          before do
            expect_any_instance_of(Survey).to receive(:save).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a survey" do
            expect do
              command.call
            end.not_to change { Survey.count }
          end
        end

        describe "when the survey is saved" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new survey with the same name as the feature" do
            expect(Survey).to receive(:new).with({
              feature: feature
            }).and_call_original

            expect do
              command.call
            end.to change { Survey.count }.by(1)
          end
        end
      end
    end
  end
end
