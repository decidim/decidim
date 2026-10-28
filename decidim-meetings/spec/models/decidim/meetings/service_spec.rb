# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Service do
      subject { service }

      let(:service) { create(:service) }

      it { is_expected.to be_valid }

      it "uses the meeting's services association as the inverse" do
        expect(service.meeting.services.first.meeting).to be(service.meeting)
      end
    end
  end
end
