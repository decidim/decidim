# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::ProposalLinkedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.accountability.proposal_linked" }
  let(:resource) { create(:result) }
  let(:proposal_component) do
    create(:component, manifest_name: "proposals", participatory_space: resource.component.participatory_space)
  end
  let(:proposal) { create :proposal, component: proposal_component }
  let(:extra) { { proposal_id: proposal.id } }
  let(:proposal_path) { resource_locator(proposal).path }
  let(:proposal_title) { proposal.title }

  before do
    resource.link_resources([proposal], "included_proposals")
  end

  it_behaves_like "a simple event"

  describe "proposal" do
    it "finds the linked proposal" do
      expect(subject.proposal).to eq(proposal)
    end
  end

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
      expect(subject.email_subject).to eq("An update to #{proposal_title}")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to eq("You have received this notification because you are following \"#{proposal_title}\". You can stop receiving notifications following the previous link.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The proposal \"#{proposal_title}\" has been included in a result. You can see it from this page:")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to eq("The proposal <a href=\"#{proposal_path}\">#{proposal_title}</a> has been included in the <a href=\"#{resource_path}\">#{resource_title}</a> result.")
    end
  end
end
