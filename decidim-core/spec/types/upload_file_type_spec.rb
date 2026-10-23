# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe UploadFileType, type: :graphql do
      include_context "with a graphql class mutation"
      let(:variables) do
        {
          input: { file: }
        }
      end

      let(:root_klass) { Decidim::Api::MutationType }
      let(:api_response) do
        response["uploadFile"]
      end
      let(:file) do
        Rack::Multipart::UploadedFile.new(
          Decidim::Dev.asset("city.jpeg"),
          "image/jpeg",
          filename: "city.jpeg"
        )
      end

      let(:query) do
        <<~GRAPHQL
          mutation($input: UploadFileInput!) {
            uploadFile(input: $input) {
              blob { id filename byteSize signedId checksum }
            }
          }
        GRAPHQL
      end

      context "with an api user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :api_user }
          let(:api_scopes) { ::Doorkeeper::OAuth::Scopes.from_array(["api:read", "api:write", "admin:read", "admin:write"]) }
        end
      end

      context "with an admin user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :admin }
        end
      end

      context "with unauthorized user" do
        it "does not upload file" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, /You do not have permission/)
        end
      end

      context "with an api user granted only the participant scopes" do
        # Uploading a file is an administrative action, so the administrative
        # scopes are required even when the token has the participant write one.
        let!(:user_type) { :api_user }

        it "does not upload the file" do
          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedFieldError, /you do not have permission/)
        end

        it "does not store the file" do
          count = ActiveStorage::Blob.count

          expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedFieldError)

          expect(ActiveStorage::Blob.count).to eq(count)
        end
      end
    end
  end
end
