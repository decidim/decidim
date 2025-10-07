# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"
require "tempfile"

module Decidim
  module Core
    describe UploadFileType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { Decidim::Api::MutationType }
      let(:api_response) do
        response["uploadFile"]
      end
      let(:file) { Tempfile.create(["valid_file", ".jpeg"]) }
      let(:query) do
        <<~GRAPHQL
          mutation($input: UploadFileInput!) {
            uploadFile(input: $input) {
              blob {
                id
                signedId
                filename
                contentType
              }
            }
          }
        GRAPHQL
      end

      let(:variables) do
        {
          "input" => { "filePath" => file.path }
        }
      end

      context "with an admin user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :admin }
        end
      end

      context "with an api user" do
        it_behaves_like "API uploadable file" do
          let!(:user_type) { :api_user }
        end
      end

      it "does not upload file for unauthorized user" do
        expect(response["uploadFile"]).to be_nil
      end
    end
  end
end