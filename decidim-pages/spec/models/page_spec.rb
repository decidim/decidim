# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe Page do
      subject { page }

      let(:page) { create(:page) }

      include_examples "has feature"

      it { is_expected.to be_valid }

      context "without a feature" do
        let(:page) { build :page, feature: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a valid feature" do
        let(:page) { build :page, feature: build(:feature, manifest_name: "proposals") }

        it { is_expected.not_to be_valid }
      end

      it "has an associated feature" do
        expect(page.feature).to be_a(Decidim::Feature)
      end
    end
  end
end
