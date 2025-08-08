# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::UpdateMeetingEvent do
  let(:resource) { create(:meeting, title: { en: "It is my meeting" }) }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.meetings.meeting_updated" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a translated meeting event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The \"#{resource_title}\" meeting was updated")
    end
  end

  describe "notification_title" do
    context "with one changed field" do
      let(:extra) { { changed_fields: ["address"] } }

      it "includes the changed field" do
        expect(subject.notification_title).to include("the address")
        expect(subject.notification_title).to include(resource_title)
        expect(subject.notification_title).to include("has been updated with changes to")
      end
    end

    context "with multiple changed fields" do
      let(:extra) { { changed_fields: %w(start_time address location) } }

      it "lists all changed fields with proper grammar" do
        expect(subject.notification_title).to include("the start time, the address, and the location")
      end
    end

    context "with no changed fields" do
      let(:extra) { { changed_fields: [] } }

      it "returns a safe fallback title when no fields are changed" do
        expect(subject.notification_title).to be_a(String)
        expect(subject.notification_title).not_to include("translation missing")
        expect(subject.notification_title).not_to include("address")
        expect(subject.notification_title).not_to include("location")
        expect(subject.notification_title).not_to include("time")
      end
    end
  end

  describe "resource_text" do
    it "returns the meeting description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end
end
