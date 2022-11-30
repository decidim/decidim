# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::CreateSortitionEvent do
  let(:resource) { create :sortition }
  let(:event_name) { "decidim.events.sortitions.sortition_created" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("New sortition added to #{participatory_space_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The sortition \"#{resource_title}\" has been added to \"#{participatory_space_title}\" that you are following.")
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
        .to eq("The sortition <a href=\"#{resource_path}\">#{resource_title}</a> has been added to #{participatory_space_title}")
    end
  end
end
