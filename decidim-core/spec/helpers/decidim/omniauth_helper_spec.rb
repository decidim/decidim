# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OmniauthHelper do
    let(:facebook_enabled) { true }
    let(:twitter_enabled) { true }
    let(:secrets) do
      {
        omniauth: {
          "facebook" => { "enabled" => facebook_enabled },
          "twitter" => { "enabled" => twitter_enabled }
        }
      }
    end

    before :each do
      allow(Rails.application).to receive(:secrets).and_return(secrets)
    end

    describe "#social_provider_enabled?" do
      describe "when the facebook provider is enabled" do
        it { expect(helper.social_provider_enabled?(:facebook)).to be_truthy }
      end

      describe "when the facebook provider is not enabled" do
        let(:facebook_enabled) { false }
        it { expect(helper.social_provider_enabled?(:facebook)).to be_falsy }
      end
    end

    describe "#any_social_provider_enabled?" do
      let(:facebook_enabled) { false }
      let(:twitter_enabled) { false }

      describe "when all providers are disabled" do
        it { expect(helper.any_social_provider_enabled?).to be_falsy }
      end
    end

    describe "#normalize_provider_name" do
      describe "when provider is google_oauth2" do
        it "returns just google" do
          expect(helper.normalize_provider_name(:google_oauth2)).to eq("google")
        end
      end
    end
  end
end
