# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::NotifyTrusteeNewElectionEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.trustees.new_election" }
  let(:resource) { create(:election) }
  let(:resource_title) { resource.title["en"] }

  it_behaves_like "a simple event"

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("You got added as a trustee for the #{resource_title} election.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you've been added as trustee for the #{resource_title} election.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("You are a trustee for <a href=\"#{resource_path}\">#{resource_title}</a> election.")
    end
  end
end
