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
      let(:admin_extensions) { extensions }
      let(:content_types) { %w(text/plain) }
      let(:admin_content_types) { content_types }
      let(:file_size) { { "default" => 5, "avatar" => 2 } }

      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => {
            "default" => extensions,
            "admin" => admin_extensions,
            "image" => extensions
          },
          "allowed_content_types" => {
            "default" => content_types,
            "admin" => admin_content_types
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

        context "when the declared content type is an accepted alias of the file extension" do
          let(:blob) do
            {
              filename: "hello.jpg",
              byte_size: 6,
              checksum:,
              content_type: "image/jpg"
            }
          end
          let(:extensions) { %w(jpg) }
          let(:content_types) { %w(image/jpg image/jpeg) }

          it "returns success" do
            post(:create, params:)

            expect(response).to have_http_status(:ok)
          end
        end
      end

      context "when the user has an elevated role" do
        # The admin allowlist is wider than the default one, so the outcome shows
        # which of them the request was checked against.
        let(:extensions) { %w(txt) }
        let(:admin_extensions) { %w(pdf) }
        let(:content_types) { %w(text/plain) }
        let(:admin_content_types) { %w(application/pdf) }
        let(:blob) do
          {
            filename: "hello.pdf",
            byte_size: 6,
            checksum:,
            content_type: "application/pdf"
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.headers["HTTP_REFERER"] = "http://#{organization.host}"
          sign_in user
        end

        context "when the user is a regular user" do
          it "checks the request against the default allowlist" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when the user is an admin of the organization" do
          let!(:user) { create(:user, :confirmed, :admin, organization:, avatar: nil) }

          it "checks the request against the admin allowlist" do
            post(:create, params:)

            expect(response).to have_http_status(:ok)
          end
        end

        context "when the user is an admin of another organization" do
          let(:organization) { create(:organization, file_upload_settings:, favicon: nil, official_img_footer: nil) }
          let!(:user) { create(:user, :confirmed, :admin, organization: create(:organization), avatar: nil) }

          it "checks the request against the default allowlist" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end

      context "when the request comes from the system panel" do
        before do
          request.env["decidim.current_organization"] = organization
          request.headers["HTTP_REFERER"] = "http://#{organization.host}"
          # The system panel admin is not an organization admin, so the validation
          # is skipped for it. A double is used because the system admin model lives
          # in decidim-system, which decidim-core does not depend on.
          allow(controller).to receive(:current_admin).and_return(double("system admin", present?: true))
        end

        let(:extensions) { %w(txt) }
        let(:blob) do
          {
            filename: "hello.pdf",
            byte_size: 6,
            checksum:,
            content_type: "application/pdf"
          }
        end

        it "skips the validation" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
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

            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when extension is not allowed" do
          let(:extensions) { %w(jpeg) }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when size is not allowed" do
          let(:file_size) { { "default" => 0, "avatar" => 0 } }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_content)
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

            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when the declared content type is not the one derived from the extension" do
          let(:blob) do
            {
              filename: "hello.png",
              byte_size: 6,
              checksum:,
              content_type: "image/jpeg"
            }
          end
          let(:extensions) { %w(png) }
          let(:content_types) { %w(image/jpeg image/png) }

          it "returns renders unprocessable entity" do
            post(:create, params:)

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end
end
