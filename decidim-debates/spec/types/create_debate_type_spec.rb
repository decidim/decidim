# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Debates
    describe CreateDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { DebatesMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:debates_component) { create(:debates_component, :with_creation_enabled, participatory_space: participatory_process) }
      let(:component) { debates_component }
      let(:title) { "Should every organization use Decidim?" }
      let(:description) { "Add your comments on whether Decidim is useful for every organization." }
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:taxonomy_ids) { [taxonomy.id.to_s] }
      let(:variables) do
        {
          input: {
            componentId: component.id.to_s,
            attributes: {
              title:,
              description:,
              taxonomyIds: taxonomy_ids
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: CreateDebateInput!) {
            createDebate(input: $input) {
              id
              title { translation(locale: "en") }
              description { translation(locale: "en") }
              taxonomies {
                name { translation(locale: "en") }
              }
            }
          }
        GRAPHQL
      end

      context "with admin user" do
        it_behaves_like "create debate mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it_behaves_like "create debate mutation examples" do
          let!(:user_type) { :user }
        end
      end

      context "with api_user" do
        it_behaves_like "create debate mutation examples" do
          let!(:user_type) { :api_user }
        end
      end

      context "when creation is not enabled" do
        let(:debates_component) { create(:debates_component, participatory_space: participatory_process) }

        it "returns an error" do
          expect(response["createDebate"]).to be_nil
        end
      end

      context "with invalid data" do
        let(:title) { "" }
        let!(:user_type) { :user }

        it "returns errors" do
          expect(response["errors"]).to be_present
        end
      end
    end
  end
end
