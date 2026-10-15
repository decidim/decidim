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
        expect(response).to have_http_status(:unprocessable_content)
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
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unallowed_file_extension" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "assemblies.json")).not_to exist
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
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unallowed_content_type" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "with an allowed extension and a spoofed content type" do
      let(:file) { Decidim::Dev.test_file("spoofed_image_html.png", "image/png") }

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unallowed_content_type" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "spoofed_image_html.png")).not_to exist
      end
    end

    context "with a declared content type which is not the one of the file contents" do
      let(:file) { Decidim::Dev.test_file("icon.png", "image/jpeg") }

      it "stores the content type detected from the file contents" do
        expect(response).to have_http_status(:ok)
        expect(ActiveStorage::Blob.last.content_type).to eq("image/png")
        expect(response.parsed_body["contentType"]).to eq("image/png")
      end
    end

    context "with a declared content type which is an alias of the detected one" do
      let(:file) { Decidim::Dev.test_file("icon.png", "image/jpg") }

      it "stores the content type detected from the file contents" do
        expect(response).to have_http_status(:ok)
        expect(ActiveStorage::Blob.last.content_type).to eq("image/png")
      end
    end

    context "with a declared content type including parameters" do
      let(:file) { Decidim::Dev.test_file("icon.png", "image/png;charset=binary") }

      it "stores the content type detected from the file contents without the parameters" do
        expect(response).to have_http_status(:ok)
        expect(ActiveStorage::Blob.last.content_type).to eq("image/png")
      end
    end

    context "with a file larger than the configured maximum" do
      let(:file_upload_settings) do
        { "maximum_file_size" => { "default" => 10.kilobytes.to_f / 1.megabyte } }
      end
      let!(:organization) { create(:organization, file_upload_settings:, favicon: nil, official_img_footer: nil) }

      it "responds with HTTP code 422" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "file_too_large" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "with a file name without an extension" do
      let(:file) do
        Decidim::Dev.test_file("city.jpeg", "image/jpeg").tap do |uploaded_file|
          uploaded_file.instance_variable_set(:@original_filename, "city")
        end
      end

      it "responds with HTTP code 422" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unallowed_file_extension" })
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
    let(:api_user) { create(:api_user, organization:, api_key:, api_secret:) }

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

    context "when the api user is not an admin" do
      let(:api_user) { create(:api_user, organization:, api_key:, api_secret:, admin: false) }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the token was issued by another organization" do
      let(:api_user) { create(:api_user, organization: create(:organization), api_key:, api_secret:) }

      it "responds with HTTP code 401" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end
  end
end
