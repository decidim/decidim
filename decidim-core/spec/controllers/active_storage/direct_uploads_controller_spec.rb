# frozen_string_literal: true

require "spec_helper"

module ActiveStorage
  describe DirectUploadsController do
    describe "POST #create" do
      let(:checksum) { OpenSSL::Digest.base64digest("MD5", "Hello") }

      let(:blob) do
        {
          filename: "hello.txt",
          byte_size: 6,
          checksum:,
          content_type: "text/plain"
        }
      end

      let(:extensions) { %w(txt) }
      let(:content_types) { %w(text/plain) }
      let(:file_size) { { "default" => 5, "avatar" => 2 } }

      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => {
            "default" => extensions,
            "admin" => extensions,
            "image" => extensions
          },
          "allowed_content_types" => {
            "default" => content_types,
            "admin" => content_types
          },
          "maximum_file_size" => file_size
        }
      end

      let(:organization) { create(:organization, file_upload_settings:, favicon: nil, official_img_footer: nil) }
      let!(:user) { create(:user, :confirmed, organization:, avatar: nil) }

      let(:params) do
        {
          blob:,
          direct_upload: blob
        }
      end

      context "when the user is not logged in" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        it "returns unauthorized" do
          post(:create, params:)

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when the organization does not exists" do
        before do
          request.env["decidim.current_organization"] = nil
          request.headers["HTTP_REFERER"] = "http://#{organization.host}"
          sign_in user
        end

        it "returns unauthorized" do
          post(:create, params:)

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when the upload is successful" do
        before do
          request.env["decidim.current_organization"] = organization
          request.headers["HTTP_REFERER"] = "http://#{organization.host}"
          sign_in user
        end

        it "returns success" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("content_type")
        end
      end

      context "when the attachment is not allowed" do
        before do
          request.env["decidim.current_organization"] = organization
          request.headers["HTTP_REFERER"] = "http://#{organization.host}"
          sign_in user
        end

        context "when content_type is not allowed" do
          let(:content_types) { %w(image/jpeg) }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when extension is not allowed" do
          let(:extensions) { %w(jpeg) }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when size is not allowed" do
          let(:file_size) { { "default" => 0, "avatar" => 0 } }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when extension not matching content_type" do
          let(:blob) do
            {
              filename: "hello.pdf",
              byte_size: 6,
              checksum:,
              content_type: "text/plain"
            }
          end

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
