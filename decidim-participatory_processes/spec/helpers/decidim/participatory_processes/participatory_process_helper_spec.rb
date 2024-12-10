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
            expect(result).to eq("01/01/2016 - 05/02/2016")
          end
        end

        describe "when the start date is not present" do
          let(:start_date) { nil }

          it "fills it in with an interrogation mark" do
            result = helper.step_dates(participatory_process)
            expect(result).to eq("? - 05/02/2016")
          end
        end

        describe "when the end date is not present" do
          let(:end_date) { nil }

          it "fills it in with an interrogation mark" do
            result = helper.step_dates(participatory_process)
            expect(result).to eq("01/01/2016 - ?")
          end
        end

        describe "available_taxonomy_filters" do
          before do
            allow(helper).to receive(:current_organization).and_return(organization)
          end

          let(:taxonomy) { create(:taxonomy, :with_parent) }
          let(:root_taxonomy) { taxonomy.parent }
          let(:organization) { root_taxonomy.organization }
          let!(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: %w(participatory_processes assemblies)) }
          let!(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: ["assemblies"]) }
          let!(:external_taxonomy_filter) { create(:taxonomy_filter, participatory_space_manifests: ["participatory_processes"]) }

          it "returns the available taxonomy filters for participatory processes" do
            expect(helper.available_taxonomy_filters).to eq([taxonomy_filter1])
          end
        end
      end
    end
  end
end
