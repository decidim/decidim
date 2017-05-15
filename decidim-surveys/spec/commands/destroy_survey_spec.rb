# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe DestroySurvey, :db do
      describe "call" do
        let(:feature) { create(:feature, manifest_name: "surveys") }
        let!(:survey)   { create(:survey, feature: feature) }
        let(:command) { described_class.new(feature) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "deletes the survey associated to the feature" do
          expect do
            command.call
          end.to change { Survey.count }.by(-1)
        end
      end
    end
  end
end
