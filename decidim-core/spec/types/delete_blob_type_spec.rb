# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe DeleteBlobType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:variables) do
        {
          input: { id: blob_id }
        }
      end

      let(:attachment) do
        create(:attachment, :with_image, attached_to: create(:participatory_process, organization: current_organization))
      end
      let(:blob) { attachment.reload.file_blob }
      let(:blob_id) { blob.id }
      let(:root_klass) { Decidim::Api::MutationType }
      let!(:type_class) { Decidim::Core::DeleteBlobType }
      let(:query) do
        %( mutation { deleteBlob(id: #{blob_id}) { id } })
      end
      let(:blob_response) { response["deleteBlob"] }

      context "with an unauthorized user" do
        let(:current_user) { nil }

        it "does not update attachment for unauthorized user" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission to perform this mutation/)
        end
      end

      context "with an API user" do
        let(:user_type) { :api_user }

        it "does not update attachment for unauthorized user" do
          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedFieldError, /you do not have permission/)
        end
      end

      context "with an admin user" do
        let(:user_type) { :admin }

        it "deletes the blob" do
          expect(blob).to be_present

          expect do
            perform_enqueued_jobs { execute_query(query, variables) }
          end.to change { ActiveStorage::Blob.exists?(blob.id) }.from(true).to(false)
        end

        it "purges the file from the storage service" do
          expect { perform_enqueued_jobs { response } }.to change { ActiveStorage::Blob.service.exist?(blob.key) }.from(true).to(false)
        end

        it "destroys the records the blob is attached to" do
          blob

          expect { response }.to change(ActiveStorage::Attachment, :count).by(-1)
        end

        it "destroys the attachment record which uses the blob" do
          blob

          expect { response }.to change(Decidim::Attachment, :count).by(-1)
        end

        it "returns the deleted attachment" do
          expect(blob_response).to eq({ "id" => blob.id.to_s })
        end

        context "when the blob is attached to an attachment in a restricted space" do
          let(:attachment) do
            create(:attachment, :with_pdf, attached_to: create(:participatory_process, :restricted, :published, organization: current_organization))
          end
          let(:query) do
            %( mutation { deleteBlob(id: #{blob_id}) { id src signedId } })
          end

          # The attachment records are destroyed before the response is built, so
          # the type can no longer see the private download requirement through
          # the blob associations; the mutation has to remember it.
          it "returns the private download url, which authorizes every request" do
            expect(blob_response["src"]).to include("/private_downloads/")
          end

          it "does not return the direct Active Storage url" do
            expect(blob_response["src"]).not_to include("/rails/active_storage/")
          end

          it "does not return the signed id, as it is a bearer credential for private files" do
            expect(blob_response["signedId"]).to be_nil
          end
        end

        context "when the blob is attached to an attachment in an open space" do
          let(:query) do
            %( mutation { deleteBlob(id: #{blob_id}) { id src signedId } })
          end

          it "returns the direct Active Storage url" do
            expect(blob_response["src"]).to include("/rails/active_storage/")
          end
        end

        context "when the same operation uploads another file" do
          # The GraphQL context is shared by every field of the operation, so the
          # attachment remembered for the deleted blob must only be used for that
          # blob. The uploaded blob has no attachments, so an unkeyed fallback would
          # make it report the deleted file's private download url and hide its own
          # signed id.
          let(:attachment) do
            create(:attachment, :with_pdf, attached_to: create(:participatory_process, :restricted, :published, organization: current_organization))
          end

          let(:schema) do
            Class.new(Decidim::Api::Schema) do
              mutation(Decidim::Api::MutationType)
              orphan_types(Decidim::Api.orphan_types)
            end
          end

          let(:variables) { { input: { file: uploaded_file } } }
          let(:uploaded_file) do
            api_upload(
              Rack::Test::UploadedFile.new(
                Decidim::Dev.asset("city.jpeg"),
                "image/jpeg",
                original_filename: "city.jpeg"
              )
            )
          end
          let(:query) do
            <<~GRAPHQL
              mutation($input: UploadFileInput!) {
                deleteBlob(id: #{blob_id}) { id src signedId }
                uploadFile(input: $input) { blob { id src signedId } }
              }
            GRAPHQL
          end

          it "keeps the private download url for the deleted blob" do
            expect(blob_response["src"]).to include("/private_downloads/")
          end

          it "returns the direct Active Storage url for the uploaded blob" do
            expect(response.dig("uploadFile", "blob", "src")).to include("/rails/active_storage/")
          end

          it "returns the signed id of the uploaded blob" do
            uploaded_blob = ActiveStorage::Blob.find(response.dig("uploadFile", "blob", "id"))

            expect(response.dig("uploadFile", "blob", "signedId")).to eq(uploaded_blob.signed_id)
          end
        end

        context "when the blob is attached to a record of another organization" do
          let(:blob) do
            create(:attachment, :with_image, attached_to: create(:participatory_process, organization: create(:organization))).reload.file_blob
          end

          it "does not delete the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission to perform this mutation/)
            expect(ActiveStorage::Blob.exists?(blob.id)).to be(true)
          end
        end

        context "when the blob is attached to another organization itself" do
          let(:blob) { create(:organization).favicon.blob }

          it "does not delete the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission to perform this mutation/)
            expect(ActiveStorage::Blob.exists?(blob.id)).to be(true)
          end
        end

        context "when the blob is also attached to a record of another organization" do
          let!(:other_attachment) do
            attachment = create(:attachment, :with_pdf, attached_to: create(:participatory_process, organization: create(:organization)))
            attachment.file.attach(blob)
            attachment
          end

          it "does not delete the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission to perform this mutation/)
            expect(ActiveStorage::Blob.exists?(blob.id)).to be(true)
          end
        end

        context "when the blob is not attached to any record" do
          let(:blob) { ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg") }

          it "does not delete the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, /Not attached/)
            expect(ActiveStorage::Blob.exists?(blob.id)).to be(true)
          end
        end

        context "when blob does not exists" do
          let(:blob_id) { 999_999 }

          it "returns the deleted attachment" do
            expect { blob_response }.to raise_error(Decidim::Api::Errors::NotFoundError, /Blob not found/)
          end
        end
      end
    end
  end
end
