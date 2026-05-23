# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "tempfile"

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

      let(:query) do
        <<~GRAPHQL
          mutation($input: UploadFileInput!) {#{" "}
            uploadFile(input: $input) {#{" "}
              blob { id filename byteSize signedId checksum }#{" "}
            }#{" "}
          }
        GRAPHQL
      end

      context "with an api user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :api_user }
        end
      end

      context "with an admin user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :admin }
        end
      end

      context "with unauthorized user" do
        let!(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
        let(:file) do
          Rack::Multipart::UploadedFile.new(
            tempfile.path,
            "image/jpg",
            filename: "foo.jpg"
          )
        end

        it "does not upload file" do
          expect(api_response).to be_nil
        end
      end
    end
  end
end
