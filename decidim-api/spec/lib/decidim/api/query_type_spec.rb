# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Api
    describe QueryType do
      include_context "with a graphql class type"

      describe "component" do
        let(:query) { %({ component(id: "#{id}") { id }}) }

        context "with a participatory space that belongs to the current organization" do
          let!(:component) { create(:dummy_component, participatory_space: participatory_process) }
          let(:participatory_process) { create(:participatory_process, organization: current_organization) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to eq("id" => component.id.to_s)
          end
        end

        context "with a participatory space that does not belong to the current organization" do
          let!(:component) { create(:dummy_component) }
          let(:id) { component.id }

          it "returns the component" do
            expect(response["component"]).to be_nil
          end
        end

        context "when requesting components from different spaces in the same query" do
          let!(:current_user) { nil }
          let!(:public_component) { create(:dummy_component, :published, participatory_space: public_process) }
          let!(:private_component) { create(:dummy_component, :published, participatory_space: private_process) }
          let(:public_process) { create(:participatory_process, :published, organization: current_organization) }
          let(:private_process) { create(:participatory_process, :published, :private, organization: current_organization) }
          let(:query) do
            %({
              publicComponent: component(id: "#{public_component.id}") { id }
              privateComponent: component(id: "#{private_component.id}") { id }
            })
          end

          it "does not expose the component from the private space" do
            expect(response["publicComponent"]).to eq("id" => public_component.id.to_s)
            expect(response["privateComponent"]).to be_nil
          end

          context "when the user is a member of the private space" do
            let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

            before do
              create(:participatory_process_user_role, participatory_process: private_process, user: current_user, role: "admin")
            end

            it "exposes both components" do
              expect(response["publicComponent"]).to eq("id" => public_component.id.to_s)
              expect(response["privateComponent"]).to eq("id" => private_component.id.to_s)
            end
          end
        end
      end

      describe "decidim" do
        let(:query) { %({ decidim { version }}) }

        it "returns nil" do
          expect(response["decidim"]).to include("version" => nil)
        end

        context "when disclosing system version is enabled" do
          before do
            allow(Decidim::Api).to receive(:disclose_system_version).and_return(true)
          end

          it "returns the right version" do
            expect(response["decidim"]).to include("version" => Decidim.version)
          end
        end
      end

      describe "organization" do
        let(:query) { %({ organization { name { translation(locale: "en") } }}) }

        it "returns the current organization" do
          expect(response["organization"]["name"]["translation"]).to eq(translated(current_organization.name))
        end
      end

      describe "users" do
        let!(:user1) { create(:user, :confirmed, organization: current_organization) }
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
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
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { "" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

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
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { user5.id.to_s }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

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
        let!(:user2) { create(:user, :confirmed, organization: current_organization) }
        let!(:user3) { create(:user, organization: current_organization) }
        let!(:user4) { create(:user, :confirmed) }
        let!(:user5) { create(:user, :confirmed, organization: current_organization) }
        let!(:user6) { create(:user, :confirmed, organization: current_organization) }
        let!(:exclusion_ids) { "#{user5.id},#{user6.id}" }

        let(:query) { %({ users(filter: { excludeIds: [#{exclusion_ids}] }) { id }}) }

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
