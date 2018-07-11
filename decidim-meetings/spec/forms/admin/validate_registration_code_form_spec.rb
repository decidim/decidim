# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::ValidateRegistrationCodeForm do
    subject(:form) do
      described_class.from_params(
        attributes
      ).with_context(current_organization: organization)
    end

    let(:organization) { create :organization }

    let(:code) { "RT67YU45" }

    let(:attributes) do
      {
        code: code
      }
    end

    it { is_expected.to be_valid }

    describe "when code is missing" do
      let(:code) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
