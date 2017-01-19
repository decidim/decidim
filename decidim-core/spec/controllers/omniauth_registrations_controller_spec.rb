# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Decidim::Devise::OmniauthRegistrationsController, type: :controller do
    let(:organization) { create(:organization) }
    
    before do
      @request.env["decidim.current_organization"] = organization
    end
    
    describe "POST create" do
      context "when the email address is already used" do
        let(:provider) { "facebook" }
        let(:uid) { "12345" }
        let(:email) { "user@from-facebook.com" }
        let!(:user) { create(:user, organization: organization, email: email)}

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

        it "redirects to new user registration path" do  
          expect(subject).to redirect_to(new_user_registration_path)
        end

        it "doesn't create a new user" do
          expect(User.count).to eq(1)
        end
      end
    end
  end
end
