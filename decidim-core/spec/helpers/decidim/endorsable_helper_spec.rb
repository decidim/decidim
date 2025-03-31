# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorsableHelper do
    describe "endorsements enabled" do
      subject { helper.endorsements_enabled? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(endorsements_enabled:))
      end

      context "when endorsements are enabled" do
        let(:endorsements_enabled) { true }

        it { is_expected.to be true }
      end

      context "when endorsements are NOT enabled" do
        let(:endorsements_enabled) { false }

        it { is_expected.to be false }
      end
    end

    describe "endorsements blocked" do
      subject { helper.endorsements_blocked? }

      before do
        allow(helper).to receive(:current_settings).and_return(double(endorsements_blocked:))
      end

      context "when endorsements are blocked" do
        let(:endorsements_blocked) { true }

        it { is_expected.to be true }
      end

      context "when endorsements are NOT blocked" do
        let(:endorsements_blocked) { false }

        it { is_expected.to be false }
      end
    end
  end
end
