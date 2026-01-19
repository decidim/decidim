# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe UpdateDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { DebateMutationType }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization: current_organization) }
      let!(:current_component) do
        create(:debates_component, :published, :with_creation_enabled, participatory_space: participatory_process, settings: {
                 taxonomy_filters: [taxonomy_filter.id]
               })
      end
      let!(:model) { create(:debate, author: current_user, component: current_component) }
      let(:title) { "Updated title" }
      let(:description) { "Updated description" }

      let(:root_taxonomy) { create(:taxonomy, organization: current_organization) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: current_organization) }
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
          input: {
            locale:,
            attributes:
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateDebateInput!) {
            update(input: $input) {
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

      shared_examples "manage debate mutation examples" do
        context "when user is the author" do
          it "updates the debate" do
            update = response["update"]
            expect(update).to be_present
            expect(update).to include(
              {
                "id" => model.id.to_s,
                "title" => {
                  "translation" => title
                },
                "description" => {
                  "translation" => description
                }
              }
            )
          end

          it "associates taxonomies with the debate" do
            debate = response["update"]
            expect(debate["taxonomies"]).to be_present
            expect(debate["taxonomies"].length).to eq(1)
            expect(debate["taxonomies"].first["name"]["translation"]).to eq(taxonomy.name["en"])
          end

          context "without taxonomies" do
            let(:taxonomies) { [] }

            it "updates a debate without taxonomies" do
              debate = response["update"]
              expect(debate).to be_present
              expect(debate["taxonomies"]).to be_empty
            end
          end
        end
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }
        let!(:model) { create(:debate, component: current_component) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when owner is not the current user" do
        let!(:model) { create(:debate, component: current_component) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "with admin user" do
        it_behaves_like "manage debate mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it_behaves_like "manage debate mutation examples"
      end

      context "with api_user" do
        it_behaves_like "manage debate mutation examples" do
          let!(:user_type) { :api_user }
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
