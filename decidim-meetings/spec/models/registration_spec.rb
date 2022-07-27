# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Registration do
    subject { registration }

    let(:meeting) { create(:meeting) }
    let(:user) { create(:user, organization: meeting.organization) }
    let(:registration) { build :registration, meeting:, user: }

    it { is_expected.to be_valid }

    context "when a registration already exists for the same user and meeting" do
      before do
        create :registration, meeting:, user:
      end

      it { is_expected.not_to be_valid }
    end

    context "when a registration with the same code already exists" do
      let(:code) { "AZ45HJ87" }

      context "when in the same meeting" do
        before do
          create :registration, meeting:, user: create(:user, organization: meeting.organization), code:
        end

        it "is invalid" do
          registration.code = code

          expect(subject).not_to be_valid
        end
      end

      context "when in another meeting" do
        before do
          create :registration, code:
        end

        it "is invalid" do
          registration.code = code

          expect(subject).to be_valid
        end
      end
    end
  end
end
