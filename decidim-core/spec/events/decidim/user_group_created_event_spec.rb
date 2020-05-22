# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroupCreatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.groups.user_group_created" }
  let(:resource) { create :user_group }
  let(:user_group_name) { CGI.escapeHTML(resource.name) }
  let(:admin_panel_url) { "http://#{organization.host}/admin/user_groups" }

  it_behaves_like "a simple event", true

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A new user group has been created")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq(%(A new user group has been created with the name #{user_group_name}. You can now verify it in the <a href="#{admin_panel_url}">admin panel</a>.))
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are an admin of the platform.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to include(%(The #{user_group_name} user group has been created. You can now verify it in the <a href="/admin/user_groups">admin panel</a>.))
    end
  end
end
