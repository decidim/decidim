# frozen_string_literal: true

require "spec_helper"
require "tempfile"

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

      context "with attachments" do
        let!(:current_component) do
          create(
            :debates_component,
            :published,
            :with_creation_enabled,
            :with_attachments_allowed,
            participatory_space: participatory_process
          )
        end

        let(:file) do
          Rack::Multipart::UploadedFile.new(
            Decidim::Dev.asset("city.jpeg"),
            "image/jpeg",
            filename: "city.jpeg"
          )
        end
        let(:attachment_title) { "Debate photo" }

        let(:attributes) do
          {
            title:,
            description:,
            attachments: [{ file:, title: attachment_title }]
          }
        end

        it_behaves_like "file upload validation rules"

        it "adds the uploaded file to the debate" do
          expect { response }.to change(Decidim::Attachment, :count).by(1)

          attachment = model.reload.attachments.detect { |attachment| attachment.title == { "en" => attachment_title } }

          expect(attachment.attached_to).to eq(model)
          expect(attachment.file.blob.filename).to eq("city.jpeg")
          expect(attachment.file.blob.content_type).to eq("image/jpeg")
        end

        it "keeps the attachments which were already attached to the debate" do
          existing = create(:attachment, attached_to: model)

          expect { response }.to change(Decidim::Attachment, :count).by(1)

          expect(model.reload.attachments.map(&:id)).to include(existing.id)
        end

        context "when the user is not the author" do
          let!(:model) { create(:debate, component: current_component) }

          it "does not store the uploaded file" do
            count = ActiveStorage::Blob.count

            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission/)

            expect(ActiveStorage::Blob.count).to eq(count)
          end
        end

        context "when the component does not allow attachments" do
          let!(:current_component) do
            create(:debates_component, :published, :with_creation_enabled, participatory_space: participatory_process)
          end

          it "raises an error and does not store the uploaded file" do
            count = ActiveStorage::Blob.count

            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /Attachments are not allowed for this component/)

            expect(ActiveStorage::Blob.count).to eq(count)
          end
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
