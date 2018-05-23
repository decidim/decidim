# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::MilestoneCompletedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.initiatives.milestone_completed" }
  let(:resource) { initiative }

  let(:initiative) { create :initiative }
  let(:extra) { { percentage: 75 } }
  let(:participatory_space) { initiative }

  it_behaves_like "a simple event"

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("New milestone completed!")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The initiative #{resource_title} has achieved the 75% of signatures!")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> initiative has achieved the 75% of signatures")
    end
  end
end
