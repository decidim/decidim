# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::CreateMeetingEvent do
  let(:resource) { create :meeting }
  let(:event_name) { "decidim.events.meetings.meeting_created" }
  let(:available_slots) { 10 }
  let(:questionnaire) { nil }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a translated meeting event"

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

  context "when in a participatory space and the registration is enabled" do
    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create :component, manifest_name: :meetings, participatory_space: participatory_process }
    let(:registrations_enabled) { true }
    let(:resource) do
      create(:meeting,
             component:,
             registrations_enabled:,
             registration_form_enabled:,
             available_slots:,
             questionnaire:)
    end

    context "when registration form is enabled" do
      let(:registration_form_enabled) { true }

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

    context "when registration form is disabled" do
      let(:registration_form_enabled) { false }

      describe "button text" do
        it "returns a register to meeting call to action" do
          expect(subject.button_text).to eq("Register to the meeting")
        end
      end

      describe "button url" do
        it "returns the link to the meeting" do
          expect(subject.button_url).to eq(Decidim::EngineRouter.main_proxy(component).meeting_url(id: resource.id, host: organization.host))
        end
      end
    end
  end
end
