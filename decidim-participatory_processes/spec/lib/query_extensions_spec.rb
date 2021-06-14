# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      describe "participatoryProcesses" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ participatoryProcesses { id }}) }

        it "returns all the processes" do
          ids = response["participatoryProcesses"].map { |pr| pr["id"] }
          # Result should be sorted by ID by default.
          expect(ids).to eq([process1, process2].map(&:id).sort.map(&:to_s))
          expect(response["participatoryProcesses"]).to include("id" => process1.id.to_s)
          expect(response["participatoryProcesses"]).to include("id" => process2.id.to_s)
          expect(response["participatoryProcesses"]).not_to include("id" => process3.id.to_s)
        end
      end

      describe "participatoryProcess" do
        let(:query) { %({ participatoryProcess(id: \"#{id}\") { id }}) }

        context "with a participatory process that belongs to the current organization" do
          let!(:process) { create(:participatory_process, organization: current_organization) }
          let(:id) { process.id }

          it "returns the process" do
            expect(response["participatoryProcess"]).to eq("id" => process.id.to_s)
          end
        end

        context "with a participatory process of another organization" do
          let!(:process) { create(:participatory_process) }
          let(:id) { process.id }

          it "returns nil" do
            expect(response["participatoryProcess"]).to be_nil
          end
        end
      end

      describe "participatoryProcessGroups" do
        let!(:group1) { create(:participatory_process_group, :with_participatory_processes, organization: current_organization) }
        let!(:group2) { create(:participatory_process_group, :with_participatory_processes, organization: current_organization) }
        let!(:group3) { create(:participatory_process_group, :with_participatory_processes) }

        let(:query) { %({ participatoryProcessGroups { id }}) }

        it "returns all the groups" do
          expect(response["participatoryProcessGroups"]).to include("id" => group1.id.to_s)
          expect(response["participatoryProcessGroups"]).to include("id" => group2.id.to_s)
          expect(response["participatoryProcessGroups"]).not_to include("id" => group3.id.to_s)
        end
      end

      describe "participatoryProcessGroup" do
        let(:query) { %({ participatoryProcessGroup(id: \"#{id}\") { id }}) }

        context "with a participatory process group that belongs to the current organization" do
          let!(:process) { create(:participatory_process_group, :with_participatory_processes, organization: current_organization) }
          let(:id) { process.id }

          it "returns the group" do
            expect(response["participatoryProcessGroup"]).to eq("id" => process.id.to_s)
          end
        end

        context "with a participatory process group of another organization" do
          let!(:process) { create(:participatory_process_group, :with_participatory_processes) }
          let(:id) { process.id }

          it "returns nil" do
            expect(response["participatoryProcessGroup"]).to be_nil
          end
        end
      end
    end
  end
end
