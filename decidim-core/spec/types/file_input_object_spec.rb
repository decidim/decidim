# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe FileInputObject, type: :graphql do
      include_context "with a graphql class mutation"

      # The input object is checked through a mutation which only resolves the
      # blob it receives, so the blob checks are exercised on their own.
      let(:type_class) do
        Class.new(Decidim::Api::Types::BaseMutation) do
          graphql_name "TestBlobInput"
          description "Test"
          type GraphQL::Types::String

          argument :attributes, Decidim::Core::AttachmentAttributes, required: true

          def resolve(attributes:)
            attributes.file.blob&.signed_id
          end
        end
      end

      let(:root_klass) { Decidim::Api::MutationType }
      let(:blob) { create(:attachment, :with_image, attached_to: create(:participatory_process, organization: current_organization)).reload.file_blob }
      let(:signed_id) { blob.signed_id }
      let(:variables) { { input: { attributes: { file: { signedId: signed_id } } } } }
      let(:query) { %(mutation($input: TestBlobInputInput!) { testBlobInput(input: $input) }) }
      let(:user_type) { :admin }

      context "with a non-admin user" do
        let(:user_type) { :user }

        it "does not return the blob" do
          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /You do not have permission to access this blob/)
        end

        context "and a signed ID which does not resolve to a blob" do
          let(:signed_id) { "tampered-signed-id" }

          it "reports the permission error instead of the missing blob, as the permission is checked first" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /You do not have permission to access this blob/)
          end
        end
      end

      context "with an admin user" do
        it "returns the blob attached to a record of the current organization" do
          expect(response["testBlobInput"]).to eq(blob.signed_id)
        end

        context "when the blob is attached to a record of another organization" do
          let(:blob) { create(:attachment, :with_image, attached_to: create(:participatory_process, organization: create(:organization))).reload.file_blob }

          it "does not return the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /You do not have permission to access this blob/)
          end
        end

        context "when the blob is also attached to a record of another organization" do
          let!(:other_attachment) do
            attachment = create(:attachment, :with_pdf, attached_to: create(:participatory_process, organization: create(:organization)))
            attachment.file.attach(blob)
            attachment
          end

          it "does not return the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /You do not have permission to access this blob/)
          end
        end

        context "when the blob is attached to another organization itself" do
          let(:blob) { create(:organization).favicon.blob }

          it "does not return the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, /You do not have permission to access this blob/)
          end
        end

        context "when the blob is not attached to any record" do
          let(:blob) { ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg") }

          it "returns the blob, as an upload which is not attached yet has no organization to check against" do
            expect(response["testBlobInput"]).to eq(blob.signed_id)
          end
        end

        context "when the signed ID has been tampered with" do
          let(:signed_id) { "eyJfcmFpbHMiOnsiZGF0YSI6MSwicHVyIjoiYmxvYl9pZCJ9fQ==--0000000000000000000000000000000000000000" }

          it "does not return the blob" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /Blob not found/)
          end
        end

        context "when the blob does not exist" do
          let(:blob) { ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg") }

          it "does not return the blob" do
            blob.purge
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /Blob not found/)
          end
        end
      end
    end
  end
end
