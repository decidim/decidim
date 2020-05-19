# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/simple_event"

describe Decidim::Elections::CreateElectionEvent do
  let(:resource) { create :election }
  let(:event_name) { "decidim.events.elections.election_created" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    subject { event_instance.email_subject }

    it "is generated correctly" do
      expect(subject).to eq("New election added to #{participatory_space_title}")
    end
  end

  describe "email_intro" do
    subject { event_instance.email_intro }

    it "is generated correctly" do
      expect(subject).to eq("The election \"#{resource_title}\" has been added to \"#{participatory_space_title}\" that you are following.")
    end
  end

  describe "email_outro" do
    subject { event_instance.email_outro }

    it "is generated correctly" do
      expect(subject).to include("You have received this notification because you are following \"#{participatory_space_title}\"")
    end
  end

  describe "notification_title" do
    subject { event_instance.notification_title }

    it "is generated correctly" do
      expect(subject).to eq("The election <a href=\"#{resource_path}\">#{resource_title}</a> has been added to #{participatory_space_title}")
    end
  end

  describe "resource_text" do
    subject { event_instance.resource_text }

    it "returns the election description" do
      expect(subject).to eq translated(resource.description)
    end
  end
end
