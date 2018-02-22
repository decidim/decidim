# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Newsletter do
    subject { newsletter }

    let(:newsletter) { build(:newsletter) }

    it { is_expected.to be_versioned }

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is not valid without a body" do
        newsletter.body = nil

        expect(subject).not_to be_valid
      end

      it "is not valid without a subject" do
        newsletter.subject = nil

        expect(subject).not_to be_valid
      end

      it "is not valid if author is from another organization" do
        user = build :user, organization: build(:organization)
        newsletter = build :newsletter, organization: build(:organization), author: user

        expect(newsletter).not_to be_valid
      end
    end
  end
end
