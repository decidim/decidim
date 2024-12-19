# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OmniauthProvider do
    let(:omniauth_secrets) do
      {
        facebook: {
          enabled: true,
          app_id: "fake-facebook-app-id",
          app_secret: "fake-facebook-app-secret"
        },
        twitter: {
          enabled: true,
          api_key: "fake-twitter-api-key",
          api_secret: "fake-twitter-api-secret"
        },
        google_oauth2: {
          enabled: false,
          client_id: nil,
          client_secret: nil
        },
        test: {
          enabled: false,
          icon: "tools-line"
        }
      }
    end

    describe "available" do
      before do
        allow(Decidim).to receive(:omniauth_providers).and_return(omniauth_secrets)
      end

      subject(:available_providers) { Decidim::OmniauthProvider.available }

      it "returns all providers" do
        expect(available_providers.size).to eq(4)
        expect(available_providers[:facebook]).to eq(omniauth_secrets[:facebook])
      end
    end

    describe "extract_provider_key" do
      subject(:provider_key) do
        Decidim::OmniauthProvider.extract_provider_key("omniauth_settings_facebook_enabled")
      end

      it "returns provider key" do
        expect(provider_key).to eq(:facebook)
      end
    end

    describe "extract_setting_key" do
      subject do
        Decidim::OmniauthProvider.extract_setting_key(setting_key, provider)
      end

      let(:setting_key) { "omniauth_settings_facebook_app_id" }
      let(:provider) { :facebook }

      it "returns the setting key without namespaces" do
        expect(subject).to eq(:app_id)
      end
    end
  end
end
