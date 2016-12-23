# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcessHelper do
    describe "#participatory_process_step_dates" do
      let(:participatory_process) do
        double(start_date: start_date, end_date: end_date)
      end

      let(:start_date) { Date.civil(2016, 1, 1) }
      let(:end_date) { Date.civil(2016, 2, 5) }

      describe "when both dates are present" do
        it "returns the formatted dates" do
          result = helper.participatory_process_step_dates(participatory_process)
          expect(result).to eq("2016-01-01 - 2016-02-05")
        end
      end

      describe "when the start date isn't present" do
        let(:start_date) { nil }

        it "fills it in with an interrogation mark" do
          result = helper.participatory_process_step_dates(participatory_process)
          expect(result).to eq("? - 2016-02-05")
        end
      end

      describe "when the end date isn't present" do
        let(:end_date) { nil }

        it "fills it in with an interrogation mark" do
          result = helper.participatory_process_step_dates(participatory_process)
          expect(result).to eq("2016-01-01 - ?")
        end
      end
    end

    describe "#feature_icon" do
      let(:feature) do
        double(manifest: double(icon: icon))
      end

      let(:icon) { "a/fake/icon.svg" }

      describe "when the feature has no icon" do
        let(:icon) { nil }

        it "returns a fallback" do
          result = helper.feature_icon(feature)
          expect(result).to include("question-mark")
        end
      end

      describe "when the feature has no icon" do
        it "returns a fallback" do
          result = helper.feature_icon(feature)
          expect(result).to include("a/fake/icon.svg")
        end
      end
    end
  end
end
