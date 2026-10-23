# frozen_string_literal: true

require "spec_helper"

describe Decidim::Api::BlobsController do
  routes { Decidim::Api::Engine.routes }

  let(:organization) { create(:organization) }
  # `Decidim::Dev.test_file` already returns a `Rack::Test::UploadedFile`. Wrapping
  # it again would make `original_filename` the name of the temporary copy instead
  # of the name of the file, which is what the blob is stored with, so the checks
  # on the stored file name below would never match anything.
  let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
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

    context "with an SVG document with active content" do
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => { "default" => extensions, "admin" => extensions },
          "allowed_content_types" => { "default" => content_types, "admin" => content_types }
        }
      end
      let(:extensions) { %w(svg) }
      let(:content_types) { %w(image/*) }
      let!(:organization) { create(:organization, file_upload_settings:) }
      let(:file) { Decidim::Dev.test_file("malicious_svg_script.svg", "image/svg+xml") }

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unsafe_content" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "malicious_svg_script.svg")).not_to exist
      end
    end

    context "with a malformed SVG document" do
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => { "default" => extensions, "admin" => extensions },
          "allowed_content_types" => { "default" => content_types, "admin" => content_types }
        }
      end
      let(:extensions) { %w(svg) }
      let(:content_types) { %w(image/*) }
      let!(:organization) { create(:organization, file_upload_settings:) }
      let(:file) { Decidim::Dev.test_file("malformed_svg_unclosed_element.svg", "image/svg+xml") }

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unsafe_content" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "malformed_svg_unclosed_element.svg")).not_to exist
      end
    end

    context "with an XML document declared as SVG" do
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => { "default" => extensions, "admin" => extensions },
          "allowed_content_types" => { "default" => content_types, "admin" => content_types }
        }
      end
      let(:extensions) { %w(svg) }
      let(:content_types) { %w(image/*) }
      let!(:organization) { create(:organization, file_upload_settings:) }
      let(:file) { Decidim::Dev.test_file("spoofed_svg_xml.svg", "image/svg+xml") }

      it "does not allow uploading a file" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq({ "error" => "unsafe_content" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "spoofed_svg_xml.svg")).not_to exist
      end
    end

    context "with a valid SVG document" do
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => { "default" => extensions, "admin" => extensions },
          "allowed_content_types" => { "default" => content_types, "admin" => content_types }
        }
      end
      let(:extensions) { %w(svg) }
      let(:content_types) { %w(image/*) }
      let!(:organization) { create(:organization, file_upload_settings:) }
      let(:file) { Decidim::Dev.test_file("test.svg", "image/svg+xml") }

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
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

    # The JWT returned by `Decidim::Api::SessionsController` is not bound to any
    # OAuth application, so there are no granted scopes to check and all of them
    # are assumed for this authentication method. The scopes can therefore only
    # restrict the requests authenticated with an OAuth token.
    it "assumes all the scopes for the credentials" do
      expect(response).to have_http_status(:ok)
    end

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

  context "with an OAuth token" do
    # The logo is not set on the application because one of the shared examples
    # lowers the maximum file size of the organization below the size of the logo
    # used by the factory, which would make the application invalid.
    let(:oauth_application) do
      create(:oauth_application, organization:, organization_logo: nil, scopes: "user api:read api:write admin:read admin:write")
    end
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    # `Decidim::OAuth::TokenGenerator` is the configured access token generator, so
    # the token of this record is the one the OAuth token endpoint returns. The
    # granted scopes are the ones stored in the record, which are the ones the
    # controller reads through `doorkeeper_token`.
    let(:access_token) do
      create(:oauth_access_token, application: oauth_application, resource_owner_id: current_user.id, scopes: token_scopes)
    end

    let(:sign_in_user) { true }

    before do
      sign_in current_user if sign_in_user

      request.headers["Authorization"] = "Bearer #{access_token.token}" if access_token
      post :create, params:
    end

    context "with the administrative read and write scopes" do
      let(:token_scopes) { "admin:read admin:write" }

      include_examples "authorized user examples"
    end

    context "with the administrative scopes together with the participant ones" do
      let(:token_scopes) { "user api:read api:write admin:read admin:write" }

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "with only the participant scopes" do
      let(:token_scopes) { "user api:read api:write" }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to eq({ "error" => "insufficient_scope" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "with only the administrative read scope" do
      let(:token_scopes) { "admin:read" }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to eq({ "error" => "insufficient_scope" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "with only the administrative write scope" do
      let(:token_scopes) { "admin:write" }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to eq({ "error" => "insufficient_scope" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "with the participant write scope and the administrative read one" do
      let(:token_scopes) { "api:read api:write admin:read" }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to eq({ "error" => "insufficient_scope" })
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "when the user is not an admin" do
      let(:token_scopes) { "admin:read admin:write" }
      let(:current_user) { create(:user, :confirmed, organization:) }

      it "responds with HTTP code 403" do
        expect(response).to have_http_status(:forbidden)
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "when the user is not authenticated" do
      let(:token_scopes) { "admin:read admin:write" }
      let(:sign_in_user) { false }

      it "responds with HTTP code 401" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not store the file" do
        expect(ActiveStorage::Blob.where(filename: "city.jpeg")).not_to exist
      end
    end

    context "when the request is authenticated without a token" do
      # Without an OAuth application the scopes are not restricted by any client,
      # so all of them are assumed for the authenticated user.
      let(:access_token) { nil }

      it "allows uploading a file" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
