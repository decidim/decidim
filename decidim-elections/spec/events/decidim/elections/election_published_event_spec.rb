# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::ElectionPublishedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.election_published" }
  let(:resource) { create(:election) }
  let(:participatory_space_title) { resource.participatory_space.title["en"] }
  let(:resource_title) { resource.title["en"] }

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The #{resource_title} election is now active for #{participatory_space_title}.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{resource_title} election is now active for #{participatory_space_title}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The <a href=\"#{resource_path}\">#{resource_title}</a> election is now active for #{participatory_space_title}.")
    end
  end
end
