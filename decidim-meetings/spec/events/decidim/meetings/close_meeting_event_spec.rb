# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::CloseMeetingEvent do
  let(:resource) { create :meeting, title: { en: "It is my overdue meeting" } }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.meetings.meeting_closed" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a translated meeting event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The \"#{resource_title}\" meeting was closed")
    end
  end

  describe "resource_text" do
    it "returns the meeting description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end

  describe "meeting closed event" do
    let!(:component) { create(:meeting_component, organization:) }
    let!(:proposal) { create(:proposal) }
    let!(:record) do
      create(
        :meeting,
        :published,
        component:,
        author: user,
        title: { en: "Event notifier" },
        description: { en: "This debate is for testing purposes" }
      )
    end
    let(:params) do
      {
        proposals: proposal,
        closing_report: "This meeting is closed for testing purposes",
        attendees_count: 1
      }
    end
    let(:form) { Decidim::Meetings::CloseMeetingForm.from_params(params) }
    let(:command) { Decidim::Meetings::Admin::CloseMeeting.new(form, record) }

    it_behaves_like "event notification"
  end
end
