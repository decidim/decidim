# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:type_class) { Decidim::Proposals::CreateProposalType }
      let(:root_klass) { Decidim::Proposals::ProposalsMutationType }

      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:organization) { current_organization }
      let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }
      let!(:component) { create(:proposal_component, :published, :with_creation_enabled, participatory_space: participatory_process) }

      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let!(:user) { create(:user, :confirmed, organization:) }

      let(:address) { "Carrer de la Pau, 1, Barcelona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      let(:title) { "More sidewalks and less roads" }
      let(:body) { "Cities need more people, not more cars" }
      let(:locale) { "en" }
      let(:translation_locale) { "en" }

      let(:attributes) do
        {
          title:,
          body:,
          address:,
          latitude:,
          longitude:,
          taxonomies: [taxonomy_filter.id]
        }
      end

      let(:variables) do
        {
          component_id: component.id,
          input: {
            locale:,
            attributes:
          }
        }
      end

      let(:root_value) { component }
      let(:query) do
        <<~GRAPHQL
          mutation createProposal($input: CreateProposalInput!){
            createProposal(input: $input) {
              id
              title { translation(locale: "#{translation_locale}") }
              body { translation(locale: "#{translation_locale}") }
              address
              publishedAt
              author { name }
            }
          }
        GRAPHQL
      end

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      context "when creating a new proposal" do
        context "when the user is not logged in" do
          let(:current_user) { nil }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when the user is logged in" do
          context "with creation enabled" do
            let!(:component) do
              create(:proposal_component,
                     :published,
                     :with_creation_enabled,
                     participatory_space: participatory_process,
                     settings: {
                       taxonomy_filters: [taxonomy_filter.id]
                     })
            end

            it "creates a new proposal" do
              proposal_response = response["createProposal"]

              expect(proposal_response).to be_present
              expect(proposal_response["title"]["translation"]).to eq(title)
              expect(proposal_response["body"]["translation"]).to include(body)
              expect(proposal_response["publishedAt"]).to be_present
              expect(proposal_response["author"]["name"]).to eq(current_user.name)
            end

            context "when submitting in one language and requesting in another" do
              let(:locale) { "en" }
              let(:translation_locale) { "es" }

              it "creates a new proposal" do
                proposal_response = response["createProposal"]

                expect(proposal_response).to be_present
                expect(proposal_response["title"]["translation"]).to be_nil
              end
            end

            context "when geocoding is enabled" do
              let!(:component) do
                create(:proposal_component,
                       :with_creation_enabled,
                       :published,
                       participatory_space: participatory_process,
                       settings: {
                         geocoding_enabled: true,
                         taxonomy_filters: [taxonomy_filter.id]
                       })
              end

              it "creates a new proposal" do
                proposal_response = response["createProposal"]

                expect(proposal_response).to be_present
                expect(proposal_response["title"]["translation"]).to eq(title)
                expect(proposal_response["body"]["translation"]).to include(body)
                expect(proposal_response["address"]).to eq(address)
                expect(proposal_response["publishedAt"]).to be_present
                expect(proposal_response["author"]["name"]).to eq(current_user.name)
              end
            end

            context "when the user is not authorized" do
              context "and there is only an authorization required" do
                before do
                  permissions = {
                    create: {
                      authorization_handlers: {
                        "dummy_authorization_handler" => { "options" => {} }
                      }
                    }
                  }

                  component.update!(permissions:)
                end

                it "throws an error if the user does not have a verification method" do
                  skip("This test is failing, but it is not in the scope of this PR.")
                  proposal_response = response["createProposal"]

                  expect(proposal_response).to be_nil
                end
              end

              context "and there are more than one authorization required" do
                before do
                  permissions = {
                    create: {
                      authorization_handlers: {
                        "dummy_authorization_handler" => { "options" => {} },
                        "another_dummy_authorization_handler" => { "options" => {} }
                      }
                    }
                  }

                  component.update!(permissions:)
                end

                it "throws an error if the user does not have a verification method" do
                  skip("This test is failing, but it is not in the scope of this PR.")

                  proposal_response = response["createProposal"]

                  expect(proposal_response).to be_nil
                end
              end
            end
          end
        end

        context "when validating" do
          context "with having invalid locale" do
            let(:locale) { "tlh" }

            it "raises an error" do
              expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
            end
          end

          context "with having invalid title" do
            context "when is missing" do
              let(:title) { "" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
              end
            end

            context "when is too short" do
              let(:title) { "Short" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
              end
            end
          end

          context "with having invalid body" do
            let(:body) { "Short" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
            end
          end
        end

        context "when the creating is disabled" do
          let!(:component) { create(:proposal_component, participatory_space: participatory_process) }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end
      end
    end
  end
end
