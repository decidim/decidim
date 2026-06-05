# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PrivateDownloadsController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:other_user) { create(:user, :confirmed, organization:) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "GET show" do
      context "with a private export" do
        let(:private_export) { create(:private_export, attached_to: user, organization:) }
        let(:token) { Decidim::PrivateDownload.for(private_export, attachment_name: :file).token }

        it "serves the file through send_data" do
          get :show, params: { locale: I18n.default_locale, id: token }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to include("attachment")
          expect(response.headers["Content-Disposition"]).to include("dummy-export.zip")
        end

        it "rejects other users" do
          token_for_other = Decidim::PrivateDownload.for(create(:private_export, attached_to: other_user, organization:), attachment_name: :file).token

          get :show, params: { locale: I18n.default_locale, id: token_for_other }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "with an authorization verification attachment" do
        let(:authorization) do
          create(
            :authorization,
            :pending,
            name: "id_documents",
            user: other_user,
            verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpeg")
          )
        end
        let(:token) { Decidim::PrivateDownload.for(authorization, attachment_name: :verification_attachment).token }

        it "allows organization admins to download" do
          admin = create(:user, :admin, :confirmed, organization:)
          sign_in admin

          get :show, params: { locale: I18n.default_locale, id: token }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("image/jpeg")
        end

        it "rejects regular users" do
          get :show, params: { locale: I18n.default_locale, id: token }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "with an attachment from a restricted space" do
        let(:restricted_process) { create(:participatory_process, :restricted, :published, organization:) }
        let(:member) { create(:member, participatory_space: restricted_process, user:) }
        let(:attachment) { create(:attachment, :with_pdf, attached_to: restricted_process) }
        let(:token) { Decidim::PrivateDownload.for(attachment, attachment_name: :file).token }

        it "allows members to download" do
          member

          get :show, params: { locale: I18n.default_locale, id: token }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("application/pdf")
        end

        it "rejects non members" do
          get :show, params: { locale: I18n.default_locale, id: token }

          expect(response).to have_http_status(:not_found)
        end
      end

      it "returns not found with an invalid token" do
        get :show, params: { locale: I18n.default_locale, id: "invalid-token" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
