# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessRoleAssignedEvent do
  include_context "when a simple event"

  let(:resource) { create :participatory_process }
  let(:event_name) { "decidim.events.participatory_process.role_assigned" }
  let(:role) { create :participatory_process_user_role, user:, participatory_process: resource, role: :admin }
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
        .to eq("You have received this notification because you are #{role} of the \"#{resource.title["en"]}\" participatory process.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("You have been assigned as #{role} for participatory process \"#{resource.title["en"]}\".")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include("You have been assigned as #{role} for participatory process <a href=\"#{resource_url}\">#{resource.title["en"]}</a>.")
    end
  end
end
