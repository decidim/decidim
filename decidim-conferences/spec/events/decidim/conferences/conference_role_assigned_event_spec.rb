# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ConferenceRoleAssignedEvent do
  include_context "when a simple event"

  let(:resource) { create :conference }
  let(:event_name) { "decidim.events.conferences.role_assigned" }
  let(:role) { create :conference_user_role, user:, conference: resource, role: :admin }
  let(:extra) { { role: } }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You have been assigned as #{role} for \"#{resource.title["en"]}\".")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are #{role} of the \"#{resource.title["en"]}\" conference.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("You have been assigned as #{role} for conference \"#{resource.title["en"]}\".")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include("You have been assigned as #{role} for conference <a href=\"#{resource_url}\">#{resource.title["en"]}</a>.")
    end
  end
end
