# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewslettersOptInController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create :organization }
    let(:user) { create(:user, :confirmed, organization:, newsletter_notifications_at: nil, newsletter_token: token) }
    let(:token) { SecureRandom.base58(24) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET update" do
      before do
        allow(controller).to receive(:current_user) { user }
      end

      context "when user uses a valid URL" do
        it "updates user newsletter settings" do
          get :update, params: { token: }
          expect(user.reload.newsletter_notifications_at).not_to be_nil
          expect(user.reload.newsletter_token).to eq("")
          expect(response).to redirect_to("/")
          expect(flash[:notice]).to include("Newsletter settings successfully updated")
        end
      end

      context "when user uses an invalid URL" do
        it "redirects to home page with an error message" do
          get :update, params: { token: "123456" }
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to include("Sorry, this link is no longer available")
        end

        it "redirect to home page because link was already used" do
          user.newsletter_opt_in_validate
          get :update, params: { token: }
          expect(response).to redirect_to("/")
          expect(flash[:alert]).to include("Sorry, this link is no longer available")
        end
      end
    end
  end
end
