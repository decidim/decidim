# frozen_string_literal: true

require "spec_helper"

describe Decidim::CapybaraTestHelpers do
  subject(:helper) { helper_class.new.tap { |instance| instance.protocol = protocol } }

  let(:helper_class) do
    Class.new do
      include Decidim::CapybaraTestHelpers

      attr_accessor :protocol
    end
  end

  describe "#data_consent_cookie_name" do
    before do
      allow(Decidim).to receive(:consent_cookie_name).and_return(configured_name)
    end

    let(:protocol) { "http" }

    context "with the default cookie name" do
      let(:configured_name) { "__Host-decidim-consent" }

      it { expect(helper.data_consent_cookie_name).to eq("decidim-consent") }

      context "when using HTTPS" do
        let(:protocol) { "https" }

        it { expect(helper.data_consent_cookie_name).to eq("__Host-decidim-consent") }
      end
    end

    context "with an unprefixed custom cookie name" do
      let(:configured_name) { "custom-consent" }

      it { expect(helper.data_consent_cookie_name).to eq("custom-consent") }

      context "when using HTTPS" do
        let(:protocol) { "https" }

        it "adds the __Host- prefix" do
          expect(helper.data_consent_cookie_name).to eq("__Host-custom-consent")
        end
      end
    end

    context "with a prefixed custom cookie name" do
      let(:configured_name) { "__Host-custom-consent" }

      it { expect(helper.data_consent_cookie_name).to eq("custom-consent") }

      context "when using HTTPS" do
        let(:protocol) { "https" }

        it "keeps the __Host- prefix" do
          expect(helper.data_consent_cookie_name).to eq("__Host-custom-consent")
        end
      end
    end
  end
end
