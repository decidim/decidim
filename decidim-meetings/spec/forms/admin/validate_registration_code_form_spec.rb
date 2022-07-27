# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::ValidateRegistrationCodeForm do
    subject(:form) do
      described_class.from_params(
        attributes
      ).with_context(current_organization: meeting.organization, meeting:)
    end

    let!(:meeting) { create :meeting }
    let!(:registration) { create(:registration, meeting:, code:) }

    let(:code) { "RT67YU45" }

    let(:attributes) do
      {
        code:
      }
    end

    it { is_expected.to be_valid }

    describe "when code is missing" do
      let(:code) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "invalid code" do
      context "when code doesn't exists" do
        let!(:registration) { create(:registration, meeting:, code: "ANOT7654") }

        it { is_expected.not_to be_valid }
      end

      context "when code is already validated" do
        let!(:registration) { create(:registration, meeting:, code:, validated_at: Time.current) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
