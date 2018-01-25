# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::UpcomingMeetingEvent do
  let(:resource) { create :meeting }
  let(:event_name) { "decidim.events.meetings.upcoming_meeting" }

  include_context "extended event"
  it_behaves_like "an extended event"
end
