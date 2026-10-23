# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "tempfile"

module Decidim
  module Core
    describe AttachmentAttributes, type: :graphql do
      include_context "with a graphql class mutation"

      # The input object is checked through the mutation which uses it, so the
      # upload checks and the permission checks are exercised together. The model
      # is created before the examples so the blobs the factory attaches to it do
      # not change the blob count during the checks.
      let!(:type_class) { Decidim::Core::CreateAttachmentType }
      let(:root_klass) { Decidim::Api::MutationType }
      let!(:model) { create(:participatory_process) }
      let(:user_type) { :admin }
      let(:query) do
        %(mutation($input: CreateAttachmentInput!) { createAttachment(input: $input) { id } })
      end
      let(:variables) do
        {
          input: {
            attributes: {
              title: { "en" => "title" },
              description: { "en" => "description" },
              file:
            }
          }
        }
      end
      let(:file) do
        Rack::Multipart::UploadedFile.new(
          Decidim::Dev.asset("city.jpeg"),
          "image/jpeg",
          filename: "city.jpeg"
        )
      end

      it_behaves_like "file upload validation rules"

      context "when everything is ok" do
        it "creates the attachment with the uploaded file" do
          expect { response }.to change(Decidim::Attachment, :count).by(1)

          attachment = Decidim::Attachment.find(response["createAttachment"]["id"])
          expect(attachment.file.blob.filename).to eq("city.jpeg")
          expect(attachment.file.blob.content_type).to eq("image/jpeg")
        end
      end

      context "when the file passes the upload checks but the model validation rejects it" do
        # An empty file with an image extension: the content type detected from the
        # name is allowed, so the blob is stored, and the attachment is then
        # rejected by the model validation, which checks the file signature.
        let(:file) do
          Rack::Multipart::UploadedFile.new(
            Tempfile.create(["empty", ".jpg"]).path,
            "image/jpeg",
            filename: "empty.jpg"
          )
        end

        it "does not create the attachment" do
          expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /The file is not a valid image/)
        end
      end

      context "with a non-admin user" do
        let(:user_type) { :user }

        it "does not store the uploaded file" do
          count = ActiveStorage::Blob.count

          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission/)

          expect(ActiveStorage::Blob.count).to eq(count)
        end
      end
    end
  end
end
