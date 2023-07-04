# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::CloseMeetingEvent do
  let(:resource) { create(:meeting, title: { en: "It is my overdue meeting" }) }
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

  describe "notification digest mail" do
    let!(:component) { create(:meeting_component, organization:, participatory_space:) }
    let(:admin) { create(:user, :admin, organization:, notifications_sending_frequency: "daily") }
    let!(:record) do
      create(
        :meeting,
        :published,
        component:,
        author: admin,
        title: { en: "Event notifier" },
        description: { en: "This meeting is for testing purposes" }
      )
    end

    let!(:follow) { create(:follow, followable: record, user:) }

    let(:params) do
      {
        closing_report: { en: "This meeting is closed" },
        video_url: "",
        audio_url: "",
        closing_visible: true,
        attendees_count: 1,
        contributions_count: 1,
        attending_organizations: ""
      }
    end

    let(:form) do
      Decidim::Meetings::Admin::CloseMeetingForm.from_params(params).with_context(
        current_component: component,
        current_user: admin,
        current_organization: organization
      )
    end
    let(:command) { Decidim::Meetings::Admin::CloseMeeting.new(form, record) }

    context "when daily notification mail" do
      let(:user) { create(:user, organization:, notifications_sending_frequency: "daily") }

      it_behaves_like "notification digest mail"
    end

    context "when weekly notification mail" do
      let(:user) { create(:user, organization:, notifications_sending_frequency: "weekly") }

      it_behaves_like "notification digest mail"
    end
  end
end
