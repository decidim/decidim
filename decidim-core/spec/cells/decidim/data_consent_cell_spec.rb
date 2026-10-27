# frozen_string_literal: true

require "spec_helper"

describe Decidim::DataConsentCell, type: :cell do
  controller Decidim::ApplicationController

  subject(:item_name) { my_cell.item_name(item) }

  let(:my_cell) { cell("decidim/data_consent", nil) }
  let(:item) { { type: "cookie", name: configured_name } }
  let(:configured_name) { Decidim.consent_cookie_name }
  let(:protocol) { "http://" }

  before do
    allow(Decidim).to receive(:consent_cookie_name).and_return(configured_name)
    allow(my_cell).to receive(:request).and_return(double(protocol:))
  end

  context "when using HTTP" do
    it "removes the __Host- prefix" do
      expect(item_name).to eq("decidim-consent")
    end

    context "when the configured name is already unprefixed" do
      let(:configured_name) { "decidim-consent" }

      it "keeps the configured name" do
        expect(item_name).to eq("decidim-consent")
      end
    end
  end

  context "when using HTTPS" do
    let(:protocol) { "https://" }
    let(:configured_name) { "custom-consent" }

    it "adds the __Host- prefix" do
      expect(item_name).to eq("__Host-custom-consent")
    end

    context "when the configured name is already prefixed" do
      let(:configured_name) { "__Host-custom-consent" }

      it "keeps the configured name" do
        expect(item_name).to eq("__Host-custom-consent")
      end
    end

    context "when the item uses the unprefixed name" do
      let(:configured_name) { "__Host-custom-consent" }
      let(:item) { { type: "cookie", name: "custom-consent" } }

      it "adds the __Host- prefix" do
        expect(item_name).to eq("__Host-custom-consent")
      end
    end
  end

  context "when the item is not the consent cookie" do
    let(:item) { { type: "cookie", name: "_session_id" } }

    it "keeps the item name" do
      expect(item_name).to eq("_session_id")
    end
  end
end
