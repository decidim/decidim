# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustees::NotifyTrusteeTallyProcessEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.elections.trustees.start_tally" }
  let(:resource) { create(:election) }
  let(:resource_title) { resource.title["en"] }

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The voting period for the #{resource_title} election has finished. Now, please, perform the tally of the election to publish the final results")
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The tally process for the #{resource_title} election has started.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The voting period for the #{resource_title} election has finished. Now, please, perform the tally of the election to publish the final results.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are a trustee for the #{resource_title} election.")
    end
  end
end
