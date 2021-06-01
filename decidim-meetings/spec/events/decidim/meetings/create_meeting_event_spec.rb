# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::CreateMeetingEvent do
  let(:resource) { create :meeting }
  let(:event_name) { "decidim.events.meetings.meeting_created" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("New meeting added to #{participatory_space_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The meeting \"#{resource_title}\" has been added to \"#{participatory_space_title}\" that you are following.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following \"#{participatory_space_title}\"")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The meeting <a href=\"#{resource_path}\">#{resource_title}</a> has been added to #{participatory_space_title}")
    end
  end

  describe "resource_text" do
    it "returns the meeting description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end

  describe "button text" do
    it "returns the nil" do
      expect(subject.button_text).to be_nil
    end
  end

  describe "button url" do
    it "returns the nil" do
      expect(subject.button_url).to be_nil
    end
  end

  context "when registration is enabled" do
    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }

    let(:registrations_enabled) { true }
    let(:available_slots) { 10 }
    let(:questionnaire) { nil }

    let(:resource) do
      create(:meeting,
             component: component,
             registrations_enabled: registrations_enabled,
             available_slots: available_slots,
             questionnaire: questionnaire)
    end

    let(:user) { create :user, :confirmed, organization: organization, email_on_notification: false }

    let(:registration_form) { Decidim::Meetings::JoinMeetingForm.new }

    describe "button text" do
      it "returns a register to meeting call to action" do
        expect(subject.button_text).to eq("Register to the meeting")
      end
    end

    describe "button url" do
      it "returns the link to join the meeting" do
        expect(subject.button_url).to eq(Decidim::EngineRouter.main_proxy(component).join_meeting_registration_url(meeting_id: resource.id, host: organization.host))
      end
    end
  end
end
