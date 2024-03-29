# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationExternalDomainAllowlistForm do
      subject do
        described_class.from_model(organization)
      end

      context "when domain allowlist is empty" do
        let(:organization) { create(:organization, external_domain_allowlist: []) }

        it { is_expected.to be_valid }
      end

      context "when everything is ok" do
        let(:organization) { create(:organization, external_domain_allowlist: ["decidim.org", "github.com", "example.org"]) }

        it { is_expected.to be_valid }
      end

      context "when allowlist item is too short" do
        let(:organization) { create(:organization, external_domain_allowlist: ["example.org", ".gg"]) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
