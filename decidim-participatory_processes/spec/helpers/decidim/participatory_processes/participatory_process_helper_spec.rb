# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessHelper do
      describe "#participatory_process_step_dates" do
        let(:participatory_process) do
          double(start_date:, end_date:)
        end

        let(:start_date) { Date.civil(2016, 1, 1) }
        let(:end_date) { Date.civil(2016, 2, 5) }

        before do
          helper.extend ParticipatoryProcessHelper
        end

        describe "when both dates are present" do
          it "returns the formatted dates" do
            result = helper.step_dates(participatory_process)
            expect(result).to eq("2016-01-01 - 2016-02-05")
          end
        end

        describe "when the start date isn't present" do
          let(:start_date) { nil }

          it "fills it in with an interrogation mark" do
            result = helper.step_dates(participatory_process)
            expect(result).to eq("? - 2016-02-05")
          end
        end

        describe "when the end date isn't present" do
          let(:end_date) { nil }

          it "fills it in with an interrogation mark" do
            result = helper.step_dates(participatory_process)
            expect(result).to eq("2016-01-01 - ?")
          end
        end
      end
    end
  end
end
