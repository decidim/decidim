# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe Decidim::Api::QueryType do
      include_context "with a graphql type"

      describe "participatoryProcesses" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ participatoryProcesses { id }}) }

        it "returns all the processes" do
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

      describe "component" do
        let(:query) { %({ component(id: \"#{id}\") { id }}) }

        context "with a participatory space that belongs to the current organization" do
          let!(:component) { create(:dummy_component, participatory_space: participatory_process) }
          let(:participatory_process) { create(:participatory_process, organization: current_organization) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to eq("id" => component.id.to_s)
          end
        end

        context "with a participatory space that doesn't belong to the current organization" do
          let!(:component) { create(:dummy_component) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to be_nil
          end
        end
      end

      describe "decidim" do
        let(:query) { %({ decidim { version }}) }

        it "returns the right version" do
          expect(response["decidim"]).to include("version" => Decidim.version)
        end
      end

      describe "organization" do
        let(:query) { %({ organization { name }}) }

        it "returns the current organization" do
          expect(response["organization"]["name"]).to eq(current_organization.name.to_s)
        end
      end
    end
  end
end
