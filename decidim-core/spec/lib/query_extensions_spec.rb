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

      describe "users" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user_group, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }

        let(:query) { %({ users { id }}) }

        it "returns all the users" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
        end
      end

      describe "users with empty exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user_group, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusionIds) { "" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusionIds}] }) { id }}) }

        it "returns all the users without any exclusion" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).to include("id" => user5.id.to_s)
          expect(response["users"]).to include("id" => user6.id.to_s)
        end
      end

      describe "users with one user exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user_group, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusionIds) { user5.id.to_s }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusionIds}] }) { id }}) }

        it "returns all the users except excluded one" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).not_to include("id" => user5.id.to_s)
          expect(response["users"]).to include("id" => user6.id.to_s)
        end
      end

      describe "users with multiple users exclusion list" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user_group, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusionIds) { "#{user5.id},#{user6.id}" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusionIds}] }) { id }}) }

        it "returns all the users except excluded ones" do
          expect(response["users"]).to include("id" => user1.id.to_s)
          expect(response["users"]).to include("id" => user2.id.to_s)
          expect(response["users"]).not_to include("id" => user3.id.to_s)
          expect(response["users"]).not_to include("id" => user4.id.to_s)
          expect(response["users"]).not_to include("id" => user5.id.to_s)
          expect(response["users"]).not_to include("id" => user6.id.to_s)
        end
      end
    end
  end
end
