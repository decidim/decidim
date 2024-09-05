# frozen_string_literal: true

require "spec_helper"

module Decidim::Dev
  class OmniauthCallbacksController < Decidim::Devise::OmniauthRegistrationsController
    def callback; end
  end
end

describe "ThirdPartyOmniauthRegistrationsController" do
  routes { Decidim::Dev::Engine.routes }

  let(:organization) { create(:organization) }

  controller(Decidim::Dev::OmniauthCallbacksController) {}

  before do
    request.env["decidim.current_organization"] = organization
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST callback" do
    let(:provider) { "custom" }
    let(:uid) { "12345" }
    let(:email) { "user@custom.example.org" }
    let!(:user) { create(:user, organization:, email:) }

    before do
      request.env["omniauth.auth"] = {
        provider:,
        uid:,
        info: {
          name: "Custom Auth",
          nickname: "custom_auth",
          email:
        }
      }
    end

    describe "after_sign_in_path_for" do
      subject { controller.after_sign_in_path_for(user) }

      context "when the user is admin who has a pending password change" do
        let(:user) { build(:user, :admin, organization:, sign_in_count: 1, password_updated_at: 1.year.ago) }

        it { is_expected.to eq("/change_password") }
      end
    end
  end
end
