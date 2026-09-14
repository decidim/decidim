# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TwoFactor do
    describe ".available_methods" do
      it "has the built-in methods registered in order" do
        expect(described_class.available_methods.map(&:name)).to eq(%w(totp email))
      end

      context "when the operator narrows the allowlist" do
        before { allow(Decidim).to receive(:two_factor_methods).and_return([:totp]) }

        it "filters the methods" do
          expect(described_class.available_methods.map(&:name)).to eq(%w(totp))
        end
      end

      context "when the organization narrows the allowlist" do
        let(:organization) { create(:organization, available_two_factor_methods: %w(email)) }

        it "intersects with the installation methods" do
          expect(described_class.available_methods(organization).map(&:name)).to eq(%w(email))
        end

        it "falls back to the installation methods when the organization has no list" do
          organization.update!(available_two_factor_methods: [])

          expect(described_class.available_methods(organization).map(&:name)).to eq(%w(totp email))
        end
      end
    end
  end
end
