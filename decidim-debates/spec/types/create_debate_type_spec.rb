# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Debates
    describe CreateDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:type_class) { Decidim::Debates::CreateDebateType }
      let(:root_klass) { Decidim::Debates::DebatesMutationType }
      let(:root_value) { current_component }

      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:organization) { current_organization }
      let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }
      let!(:current_component) do
        create(:debates_component, :published, :with_creation_enabled, participatory_space: participatory_process, settings: {
                 taxonomy_filters: [taxonomy_filter.id]
               })
      end

      let(:title) { "Should every organization use Decidim?" }
      let(:description) { "Add your comments on whether Decidim is useful for every organization." }

      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let!(:taxonomies) { [taxonomy.id] }

      let(:locale) { "en" }
      let(:translation_locale) { "en" }

      let(:attributes) do
        {
          title:,
          description:,
          taxonomies:
        }
      end

      let(:variables) do
        {
          component_id: current_component.id,
          input: {
            locale:,
            attributes:
          }
        }
      end

      let(:query) do
        <<~GRAPHQL
          mutation createDebate($input: CreateDebateInput!) {
            createDebate(input: $input) {
              id
              title { translation(locale: "en") }
              description { translation(locale: "en") }
              taxonomies {
                name { translation(locale: "en") }
              }
              author { id }
            }
          }
        GRAPHQL
      end

      shared_examples "create debate mutation examples" do
        context "when creation is enabled" do
          it "creates a debate" do
            debate = response["createDebate"]
            expect(debate).to be_present
            expect(debate["id"]).to be_present
            expect(debate["title"]["translation"]).to eq(title)
            expect(debate["description"]["translation"]).to eq(description)
          end

          it "associates taxonomies with the debate" do
            debate = response["createDebate"]
            expect(debate["taxonomies"]).to be_present
            expect(debate["taxonomies"].length).to eq(1)
            expect(debate["taxonomies"].first["name"]["translation"]).to eq(taxonomy.name["en"])
          end

          context "without taxonomies" do
            let(:taxonomies) { [] }

            it "creates a debate without taxonomies" do
              debate = response["createDebate"]
              expect(debate).to be_present
              expect(debate["taxonomies"]).to be_empty
            end
          end
        end
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
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
        let(:current_component) { create(:debates_component, :published, participatory_space: participatory_process) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when validating" do
        let!(:user_type) { :user }

        context "with having invalid locale" do
          let(:locale) { "tlh" }

          it "raises an error" do
            expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "and title is missing" do
          let(:title) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "and description is missing" do
          let(:description) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end
      end
    end
  end
end
