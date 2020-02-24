# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OmniauthHelper do
    let(:facebook_enabled) { true }
    let(:twitter_enabled) { true }
    let(:secrets) do
      {
        omniauth: {
          facebook: { enabled: facebook_enabled },
          twitter: { enabled: twitter_enabled }
        }
      }
    end

    before do
      allow(Rails.application).to receive(:secrets).and_return(secrets)
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
