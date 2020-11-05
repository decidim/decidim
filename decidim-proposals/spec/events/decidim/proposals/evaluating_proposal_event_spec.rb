# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::EvaluatingProposalEvent do
  let(:resource) { create :proposal, title: "My super proposal" }
  let(:event_name) { "decidim.events.proposals.proposal_evaluating" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A proposal you're following is being evaluated")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The proposal \"#{translated(resource.title)}\" is currently being evaluated. You can check for an answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{translated(resource.title)}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("The <a href=\"#{resource_path}\">#{translated(resource.title)}</a> proposal is being evaluated")
    end
  end
end
