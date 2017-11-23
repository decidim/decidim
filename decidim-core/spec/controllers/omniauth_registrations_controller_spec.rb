# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Devise::OmniauthRegistrationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "POST create" do
      context "when the unverified email address is already in use" do
        subject do
          post :create, params: {
            user: {
              provider: provider,
              uid: uid,
              name: "Facebook User",
              email: email,
              oauth_signature: OmniauthRegistrationForm.create_signature(provider, uid)
            }
          }
        end

        let(:provider) { "facebook" }
        let(:uid) { "12345" }
        let(:email) { "user@from-facebook.com" }
        let!(:user) { create(:user, organization: organization, email: email) }

        it "doesn't create a new user" do
          expect(User.count).to eq(1)
        end

        it "doesn't log in" do
          expect(controller).not_to be_user_signed_in
        end
      end
    end
  end
end
