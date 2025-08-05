# frozen_string_literal: true

require "spec_helper"

describe Decidim::Api::BlobsController do
  routes { Decidim::Api::Engine.routes }

  let(:organization) { create(:organization) }
  let(:file) do
    Rack::Test::UploadedFile.new(
      Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
      "image/jpeg"
    )
  end
  let(:params) { { file: } }

  before do
    request.env["decidim.current_organization"] = organization
  end

  shared_examples_for "authorized user examples" do
    it "allows uploading a file" do
      expect(response).to have_http_status(:ok)
    end

    context "with invalid params" do
      let(:params) { { file: "foobar" } }

      it "responds with HTTP code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq({ "error" => "file_not_provided" })
      end
    end

    context "with unallowed file extension" do
      let(:file) do
        Rack::Test::UploadedFile.new(
          Decidim::Dev.test_file("assemblies.json", "application/json"),
          "application/json"
        )
      end
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => {
            "default" => extensions,
            "admin" => extensions
          }
        }
      end
      let(:extensions) { %w(jpg jpeg) }
      let(:content_types) { %w(image/jpeg) }
      let!(:organization) { create(:organization, file_upload_settings:) }

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq({ "error" => "unallowed_file_extension" })
      end
    end

    context "with unallowed content type" do
      let(:file) do
        Rack::Test::UploadedFile.new(
          Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
          "application/zip"
        )
      end

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq({ "error" => "unallowed_content_type" })
      end
    end

    context "with file name in Windows-1252 encoding" do
      let(:file) do
        Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf").tap do |f|
          # In case we stored a file with such name in the "fixtures" folder,
          # this would not work because `rack-test` fails to generate the
          # `Rack::Test::UploadedFile` due to the weird name. We need to force
          # the name on the instance in order to replicate the bug with
          # storing file names with this encoding. There is no other way to
          # change the "original_filename" of the instance.
          f.instance_variable_set(:@original_filename, "êxämplö®'.pdf".encode("WINDOWS-1252"))
        end
      end

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "with normal user" do
    context "when the user is not authenticated" do
      before do
        post :create, params:
      end

      it "responds with HTTP code 401" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when the user is authenticated" do
      before do
        sign_in current_user

        post :create, params:
      end

      context "and the user is a regular user" do
        let(:current_user) { create(:user, :confirmed, organization:) }

        it "responds with HTTP code 403" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "and the user is an admin" do
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }

        include_examples "authorized user examples"
      end
    end
  end

  context "with an api user" do
    let(:api_key) { "user_key" }
    let(:api_secret) { "decidim123456789" }
    let(:api_user) { create(:api_user, organization: organization, api_key: api_key, api_secret: api_secret) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:api_user]
      request.env[Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY] = "warden-jwt_auth.token_dispatcher"
      request.env["decidim.current_organization"] = organization
      # manually add the token to the request to imitate the sign in process
      token, = Warden::JWTAuth::UserEncoder.new.call(api_user, :api_user, nil)
      request.headers["Authorization"] = "Bearer #{token}"
      post :create, params:
    end

    include_examples "authorized user examples"
  end
end
