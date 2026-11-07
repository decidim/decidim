# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Poll do
      subject { poll }

      let(:poll) { create(:poll) }

      it { is_expected.to be_valid }

      it "uses the meeting's poll association as the inverse" do
        expect(poll.meeting.poll.meeting).to be(poll.meeting)
      end
    end
  end
end
