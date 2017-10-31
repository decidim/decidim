# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Registration do
    subject { registration }

    let(:meeting) { create(:meeting) }
    let(:user) { create(:user, organization: meeting.organization) }
    let(:registration) { build :registration, meeting: meeting, user: user }

    it { is_expected.to be_valid }

    context "when a registration already exists for the same user and meeting" do
      before do
        create :registration, meeting: meeting, user: user
      end

      it { is_expected.not_to be_valid }
    end
  end
end
