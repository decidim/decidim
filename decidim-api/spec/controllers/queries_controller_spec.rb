# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Api
    describe QueriesController do
      routes { Decidim::Api::Engine.routes }

      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when the organization has private access" do
        let(:organization) do
          create(
            :organization,
            force_users_to_authenticate_before_access_organization: true
          )
        end

        it "does not accept queries" do
          post :create, params: { query: "{ __schema { queryType { name } } }" }

          expect(response).to redirect_to(new_user_session_path)
        end
      end

      it "executes a query" do
        post :create, params: { query: "{ organization { name { translations { locale text } } } }" }

        parsed_response = response.parsed_body["data"]
        expect(parsed_response["organization"]["name"]["translations"]).to include("locale" => "en", "text" => translated(organization.name))
      end

      describe "multipart requests" do
        let(:operations) do
          {
            query: "mutation ($input: UploadFileInput!) { uploadFile(input: $input) { blob { id filename } } }",
            variables: { input: { file: nil } }
          }.to_json
        end
        let(:map) { { "0" => ["variables.input.file"] }.to_json }
        let(:uploaded_file) do
          Rack::Test::UploadedFile.new(Decidim::Dev.test_file("city.jpeg", "image/jpeg"), "image/jpeg")
        end

        context "when the request is valid" do
          let(:current_user) { create(:user, :confirmed, :admin, organization:) }

          before do
            sign_in current_user
          end

          it "assigns the uploaded file to the mapped path" do
            post :create, params: { operations:, map: }.merge("0" => uploaded_file)

            expect(response).to have_http_status(:success)
            expect(response.parsed_body.dig("data", "uploadFile", "blob", "filename")).to match(/\Acity.*\.jpeg\z/)
          end
        end

        context "when the mapped file is missing" do
          it "returns a client error" do
            post :create, params: { operations:, map: }

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to eq("Uploaded file missing in params[0]")
          end
        end

        context "when the map contains an invalid path" do
          it "returns a client error" do
            invalid_map = { "0" => ["variables.missing.file"] }.to_json

            post :create, params: { operations:, map: invalid_map }.merge("0" => uploaded_file)

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to include("Unsupported path segment :missing")
          end
        end

        context "when the operations payload is not valid JSON" do
          it "returns a client error" do
            post :create, params: { operations: "{not valid json", map: }

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to eq("The operations parameter is not valid JSON")
          end
        end

        context "when the map payload is not valid JSON" do
          it "returns a client error" do
            post :create, params: { operations:, map: "{not valid json" }

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to eq("The map parameter is not valid JSON")
          end
        end

        context "when the map is empty" do
          it "returns a client error" do
            post :create, params: { operations:, map: "{}" }

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to eq("Invalid multipart map")
          end
        end

        context "when the map paths are not an array of strings" do
          it "returns a client error" do
            post :create, params: { operations:, map: { "0" => "variables.input.file" }.to_json }

            expect(response).to have_http_status(:bad_request)
            expect(response.parsed_body["errors"].first["message"]).to include("must be a non-empty array of strings")
          end
        end
      end

      context "with force sign in enabled" do
        before do
          allow(Decidim::Api).to receive(:force_api_authentication).and_return(true)
        end

        context "when user is not signed in" do
          it "redirects to login page for HTML requests" do
            post :create, params: {}
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_user_session_path)
          end

          it "returns 401 Unauthorized for JSON requests" do
            post :create, params: {}, format: :json
            expect(response).to have_http_status(:unauthorized)
          end
        end

        context "when user is signed in" do
          let(:current_user) { create(:user, :confirmed, :admin, organization:) }

          before do
            sign_in current_user
          end

          it "allows access for HTML requests" do
            post :create, params: {}
            expect(response).to have_http_status(:success)
          end

          it "allows access for JSON requests" do
            post :create, params: { query: "{ __schema { queryType { name } } }" }, format: :json
            expect(response).to have_http_status(:success)
          end
        end

        context "when the signed in user belongs to another organization" do
          let(:current_user) { create(:user, :confirmed, :admin, organization: create(:organization)) }

          before do
            sign_in current_user
          end

          it "does not expose the session" do
            post :create, params: { query: "{ session { user { id } } }" }, format: :json

            parsed_response = response.parsed_body["data"]
            expect(parsed_response).to match("session" => nil)
          end
        end
      end
    end
  end
end
