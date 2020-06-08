# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    describe Template do
      subject { template }

      let(:template) { create(:template) }

      it { is_expected.to be_valid }

      context "without an organization" do
        let(:template) { build :template, organization: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a templatable" do
        let(:template) { build :template, templatable: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated templatable" do
        expect(template.templatable).to be_a(Decidim::DummyResources::DummyResource)
      end
    end
  end
end
