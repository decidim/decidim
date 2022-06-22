# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingRegistrationsEnabledEvent do
  let(:resource) { create :meeting, title: { en: "It's my meeting" } }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.meetings.registrations_enabled" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a translated meeting event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The \"#{resource_title}\" meeting has enabled registrations.")
    end
  end

  describe "resource_text" do
    it "returns the meeting description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end
end
