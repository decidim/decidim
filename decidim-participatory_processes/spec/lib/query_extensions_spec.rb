# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

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
