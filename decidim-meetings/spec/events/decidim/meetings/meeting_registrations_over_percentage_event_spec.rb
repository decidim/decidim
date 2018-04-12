# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingRegistrationsOverPercentageEvent do
  include_context "when a simple event"

  let(:resource) { create :meeting }
  let(:event_name) { "decidim.events.meetings.meeting_registrations_over_percentage" }
  let(:extra) { { percentage: 1.1 } }

  it_behaves_like "a simple event"
end
