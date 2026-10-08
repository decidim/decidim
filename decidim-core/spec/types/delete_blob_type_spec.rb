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

      let(:blob) do
        create(:attachment, :with_image, attached_to: create(:participatory_process, organization: current_organization)).reload.file_blob
      end
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
            execute_query(query, variables)
          end.to change { ActiveStorage::Blob.exists?(blob.id) }.from(true).to(false)
        end

        it "returns the deleted attachment" do
          expect(blob_response).to eq({ "id" => blob.id.to_s })
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
