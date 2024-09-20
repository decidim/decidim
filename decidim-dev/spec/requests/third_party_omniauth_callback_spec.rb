# frozen_string_literal: true

require "spec_helper"

module Decidim::Dev
  # This controller simulates a customized Omniauth callback flow that would be
  # used by 3rd party login providers. Such providers may need to customize how
  # the login callback is handled based on conditions returned by the Omniauth
  # provider. Customizing the Omniauth strategy is not enough when the login
  # provider needs access to the Decidim context.
  class OmniauthCallbacksController < Decidim::Devise::OmniauthRegistrationsController
    def dev_callback
      create
    end
  end
end

RSpec.describe "Omniauth callback" do
  subject { response.body }

  let(:organization) { create(:organization) }

  let(:user) { create(:user, :confirmed, organization:, email: "user@example.org", password: "decidim123456789") }

  let(:oauth_hash) do
    {
      provider: "test",
      uid:,
      info: {
        name: "Custom Auth",
        nickname: "custom_auth",
        email:
      }
    }
  end

  before do
    host! organization.host
  end

  describe "POST callback" do
    let(:request_path) { "/users/auth/test/callback" }

    let(:uid) { "12345" }
    let(:email) { "user@custom.example.org" }

    context "with a new user" do
      it "shows the create an account form" do
        get(request_path, env: { "omniauth.auth" => oauth_hash })

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Create an account")
        expect(response.body).to include("Terms of Service")
      end
    end

    context "with existing user" do
      let!(:user) { create(:user, organization:, email:) }

      it "redirects to root" do
        get(request_path, env: { "omniauth.auth" => oauth_hash })

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/")
      end
    end

    context "when the user is admin with a pending password change" do
      let!(:user) { create(:user, :confirmed, :admin, organization:, email:, sign_in_count: 1, password_updated_at: 1.year.ago) }

      it "redirects to the /change_password path" do
        get(request_path, env: { "omniauth.auth" => oauth_hash })

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/change_password")
      end
    end
  end
end
