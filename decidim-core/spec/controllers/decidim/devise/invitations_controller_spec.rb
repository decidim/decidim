# frozen_string_literal: true

require "spec_helper"

module Decidim::Devise
  describe InvitationsController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:inviter) { create(:user, :admin, organization:) }
    let(:invitation_params) do
      {
        organization:,
        name: "Invited User",
        email: "inviteduser@example.org"
      }
    end
    let!(:user) { Decidim::User.invite!(invitation_params, inviter) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["devise.mapping"] = ::Devise.mappings[:user]
    end

    describe "accepting invitation" do
      let(:password) { "decidim123456789" }
      let(:registration_params) do
        {
          invitation_token: user.raw_invitation_token,
          nickname: "invited_user",
          password:
        }
      end

      it "responds to the edit path" do
        get :edit, params: { invitation_token: user.raw_invitation_token }
        expect(response).to have_http_status(:ok)
      end

      it "redirects to the provided path" do
        post :update, params: { user: registration_params }
        expect(response).to redirect_to("/")
      end

      context "when an invite redirect is provided" do
        it "redirects to the redirect path" do
          post :update, params: { invite_redirect: "/admin/", user: registration_params }
          expect(response).to redirect_to("/admin/")
        end

        context "with a full HTTP URL" do
          it "redirects to the default path" do
            post :update, params: { invite_redirect: "http://example.org", user: registration_params }
            expect(response).to redirect_to("/")
          end
        end

        context "with a full HTTPS URL" do
          it "redirects to the default path" do
            post :update, params: { invite_redirect: "https://example.org", user: registration_params }
            expect(response).to redirect_to("/")
          end
        end

        context "with a URL without protocol" do
          it "redirects to the default path" do
            post :update, params: { invite_redirect: "//example.org", user: registration_params }
            expect(response).to redirect_to("/")
          end
        end
      end
    end
  end
end
