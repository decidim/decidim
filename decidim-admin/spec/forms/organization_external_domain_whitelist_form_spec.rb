# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationExternalDomainWhitelistForm do
      subject do
        described_class.from_model(organization)
      end

      let(:organization) { create(:organization, external_domain_whitelist: ["example.org"]) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
