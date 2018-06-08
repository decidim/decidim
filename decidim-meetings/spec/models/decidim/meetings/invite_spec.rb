# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Invite do
      subject { invite }

      let(:invite) { create(:invite) }

      it { is_expected.to be_valid }

      it "has an associated meeting" do
        expect(invite.meeting).to be_a(Decidim::Meetings::Meeting)
      end

      it "has an associated user" do
        expect(invite.user).to be_a(Decidim::User)
      end

      context "without a meeting" do
        let(:invite) { build :invite, meeting: nil }

        it { is_expected.not_to be_valid }
      end

      context "without an user" do
        let(:invite) { build :invite, user: nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
