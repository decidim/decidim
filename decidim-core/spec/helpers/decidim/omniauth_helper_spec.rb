# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe OmniauthHelper do
    let(:facebook_enabled) { true }    
    let(:twitter_enabled) { true }
    let(:omniauth) do
      { 
        "facebook" => { "enabled" => facebook_enabled },
        "twitter" => { "enabled" => twitter_enabled }
      }
    end

    before :each do
      allow(Rails.application.secrets).to receive(:omniauth).and_return(omniauth)
    end
    
    describe "#social_provider_enabled?" do
      describe "when the facebook provider is enabled" do
        it { expect(helper.social_provider_enabled? :facebook).to be_truthy }
      end

      describe "when the facebook provider is not enabled" do
        let(:facebook_enabled) { false }
        it { expect(helper.social_provider_enabled? :facebook).to be_falsy }
      end
    end

    describe "#any_social_provider_enabled?" do
      let(:facebook_enabled) { false }
      let(:twitter_enabled) { false }
      
      describe "when all providers are disabled" do
        it { expect(helper.any_social_provider_enabled?).to be_falsy }
      end
    end
  end
end
