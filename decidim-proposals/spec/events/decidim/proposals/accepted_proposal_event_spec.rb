# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AcceptedProposalEvent do
  let(:resource) { create :proposal, :with_answer, title: "My super proposal" }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.proposal_accepted" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A proposal you're following has been accepted")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The proposal \"#{resource_title}\" has been accepted. You can read the answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> proposal has been accepted")
    end
  end

  describe "resource_text" do
    it "shows the proposal answer" do
      expect(subject.resource_text).to eq translated(resource.answer)
    end
  end
end
