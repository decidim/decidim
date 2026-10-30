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
      let(:author) { create(:user, :confirmed, organization:) }
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

      around do |example|
        I18n.with_locale(:en) do
          example.run
        end
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

      context "with attachments" do
        let!(:current_user) { author }

        let(:proposal_component) do
          create(
            :proposal_component,
            participatory_space: participatory_process,
            settings: {
              taxonomy_filters: [taxonomy_filter.id],
              attachments_allowed: true
            }
          )
        end

        let(:file) do
          Rack::Multipart::UploadedFile.new(
            Decidim::Dev.asset("city.jpeg"),
            "image/jpeg",
            filename: "city.jpeg"
          )
        end
        let(:attachment_title) { "Sidewalk photo" }

        let(:variables) do
          {
            input: {
              locale:,
              attributes: {
                title: new_title,
                body: new_body,
                attachments: [{ file:, title: attachment_title }]
              }
            }
          }
        end

        it_behaves_like "file upload validation rules"

        it "adds the uploaded file to the proposal" do
          expect { response }.to change(Decidim::Attachment, :count).by(1)

          attachment = model.reload.attachments.detect { |attachment| attachment.title == { "en" => attachment_title } }

          expect(attachment.attached_to).to eq(model)
          expect(attachment.file.blob.filename).to eq("city.jpeg")
          expect(attachment.file.blob.content_type).to eq("image/jpeg")
        end

        it "keeps the attachments which were already attached to the proposal" do
          existing = create(:attachment, attached_to: model)

          expect { response }.to change(Decidim::Attachment, :count).by(1)

          expect(model.reload.attachments.map(&:id)).to include(existing.id)
        end

        context "when the user is not the author" do
          let!(:current_user) { create(:user, :confirmed, organization:) }

          it "does not store the uploaded file" do
            count = ActiveStorage::Blob.count

            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission/)

            expect(ActiveStorage::Blob.count).to eq(count)
          end
        end

        context "when the component does not allow attachments" do
          let(:proposal_component) do
            create(
              :proposal_component,
              participatory_space: participatory_process,
              settings: { taxonomy_filters: [taxonomy_filter.id] }
            )
          end

          it "raises an error and does not store the uploaded file" do
            count = ActiveStorage::Blob.count

            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /Attachments are not allowed for this component/)

            expect(ActiveStorage::Blob.count).to eq(count)
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
