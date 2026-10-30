# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "tempfile"

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

      context "with attachments" do
        let!(:user_type) { :user }

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

        it "creates the debate with the uploaded file" do
          expect { response }.to change(Decidim::Attachment, :count).by(1)

          debate = Decidim::Debates::Debate.find(response["createDebate"]["id"])
          attachment = debate.attachments.first

          expect(attachment.attached_to).to eq(debate)
          expect(attachment.title).to eq({ "en" => attachment_title })
          expect(attachment.file.blob.filename).to eq("city.jpeg")
          expect(attachment.file.blob.content_type).to eq("image/jpeg")
        end

        context "when the title is not given" do
          let(:attributes) do
            {
              title:,
              description:,
              attachments: [{ file: }]
            }
          end

          it "creates the attachment with an empty title" do
            response

            attachment = Decidim::Debates::Debate.find(response["createDebate"]["id"]).attachments.first
            expect(attachment.title).to eq({ "en" => "" })
          end
        end

        context "when the file is only allowed for administrators" do
          # The participant allowlists are narrower than the administrative ones, so
          # a document an administrator can upload is refused for the participant who
          # creates the debate.
          let!(:tempfile) { Tempfile.create(["report", ".docx"]) }
          let(:file) do
            Rack::Multipart::UploadedFile.new(
              tempfile.path,
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
              filename: "report.docx"
            )
          end

          it "does not store the uploaded file" do
            count = ActiveStorage::Blob.count

            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /File extension is not supported./)

            expect(ActiveStorage::Blob.count).to eq(count)
          end
        end

        context "when the user is not allowed to create debates" do
          let!(:current_user) { nil }

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
