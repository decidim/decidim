# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let!(:taxonomies) { [taxonomy.id] }

      let(:type_class) { Decidim::Proposals::UpdateProposalType }
      let(:root_klass) { ProposalMutationType }
      let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
      let(:current_organization) { organization }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process, settings: { taxonomy_filters: [taxonomy_filter.id] }) }
      let(:current_component) { proposal_component }
      let(:author) { create(:user, organization:) }
      let!(:model) { create(:proposal, component: proposal_component, users: [author]) }
      let(:root_value) { model }
      let(:new_title) { "Updated proposal title for testing" }
      let(:new_body) { "This is an updated body content for the proposal that meets the minimum length requirements." }
      let(:component) { model.component }
      let(:locale) { "en" }
      let(:variables) do
        {
          input: {
            locale:,
            attributes: {
              title: new_title,
              body: new_body,
              taxonomies:
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: UpdateProposalInput!) {
            updateProposal(input: $input) {
              id
              title { translation(locale: "#{locale}") }
              body { translation(locale: "#{locale}") }
              address
              taxonomies { id }
            }
          }
        GRAPHQL
      end

      before do
        I18n.locale = "en"
      end

      shared_examples "update proposal mutation examples" do
        context "when user is not authorized" do
          let!(:current_user) { nil }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when user is authorized" do
          context "with valid attributes" do
            context "when requesting a different locale" do
              let!(:model) { create(:proposal, title: { "en" => "Original title", "ca" => "Títol original" }, component: proposal_component, users: [author]) }
              let(:locale) { "ca" }

              it "updates only the language" do
                update = response["updateProposal"]
                expect(update).to be_present
                expect(update["title"]).to include({ "translation" => new_title })

                expect(model.reload.title).to include({ "ca" => new_title })
              end
            end

            it "updates the proposal" do
              update = response["updateProposal"]

              expect(update).to be_present
              expect(update).to include(
                {
                  "id" => model.id.to_s,
                  "title" => {
                    "translation" => new_title
                  },
                  "body" => {
                    "translation" => new_body
                  }
                }
              )
              expect(update["taxonomies"]).to include({ "id" => taxonomy.id.to_s })
            end

            context "with address and coordinates" do
              let(:address) { "Carrer de la Pau, 1, Barcelona" }
              let(:latitude) { 41.3851 }
              let(:longitude) { 2.1734 }
              let(:variables) do
                {
                  input: {
                    locale:,
                    attributes: {
                      title: new_title,
                      body: new_body,
                      address:,
                      latitude:,
                      longitude:
                    }
                  }
                }
              end

              it "updates the proposal with location data" do
                update = response["updateProposal"]
                expect(update).to be_present
                expect(update).to include(
                  {
                    "id" => model.id.to_s,
                    "address" => address
                  }
                )
              end
            end
          end

          context "with invalid attributes" do
            let(:new_title) { "short" }
            let(:new_body) { "x" }

            it "returns an error" do
              expect { response }.to raise_error(StandardError)
            end
          end
        end
      end

      context "with proposal author" do
        let!(:current_user) { author }

        it_behaves_like "update proposal mutation examples" do
          let!(:user_type) { :user }
        end

        context "with having invalid locale" do
          let(:locale) { "tlh" }

          it "raises an error" do
            expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "with invalid attributes" do
          context "with invalid title" do
            context "when is missing" do
              let(:new_title) { "" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
              end
            end

            context "when is too short" do
              let(:new_title) { "Short" }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
              end
            end

            context "when is all small" do
              let(:new_title) { "Updated proposal title for testing".downcase }

              it "raises an error" do
                expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /must start with a capital letter/)
              end
            end
          end

          context "with invalid body" do
            let(:new_body) { "Short" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /too short/)
            end
          end
        end
      end

      context "with admin user" do
        let!(:user_type) { :admin }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "with normal user (not author)" do
        it "raises an Decidim::Api::Errors::MutationNotAuthorizedError exception" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "with api_user" do
        let!(:current_user) { author }

        it_behaves_like "update proposal mutation examples" do
          let!(:user_type) { :api_user }
        end
      end
    end
  end
end
