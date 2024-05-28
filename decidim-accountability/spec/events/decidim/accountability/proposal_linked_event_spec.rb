# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::ProposalLinkedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.accountability.proposal_linked" }
  let(:resource) { create(:result, title: generate_localized_title(:result_title)) }
  let(:proposal_component) do
    create(:component, manifest_name: "proposals", participatory_space: resource.component.participatory_space)
  end
  let(:proposal) { create(:proposal, component: proposal_component) }
  let(:extra) { { proposal_id: proposal.id } }
  let(:proposal_path) { resource_locator(proposal).path }
  let(:proposal_title) { decidim_sanitize_translated(proposal.title) }
  let(:notification_title) { "The proposal <a href=\"#{proposal_path}\">#{proposal_title}</a> has been included in the <a href=\"#{resource_path}\">#{resource_title}</a> result." }
  let(:email_subject) { "An update to #{proposal_title}" }
  let(:email_outro) { "You have received this notification because you are following \"#{proposal_title}\". You can stop receiving notifications following the previous link." }
  let(:email_intro) { "The proposal \"#{proposal_title}\" has been included in a result. You can see it from this page:" }

  before do
    resource.link_resources([proposal], "included_proposals")
  end

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

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
      expect(subject.email_subject).not_to include(proposal.title.to_s)
      expect(subject.email_subject).to include(proposal_title)
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).not_to include(proposal.title.to_s)
      expect(subject.email_outro).to include(proposal_title)
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).not_to include(proposal.title.to_s)
      expect(subject.email_intro).to include(proposal_title)
    end
  end

  describe "resource_text" do
    it "outputs the localized result description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end

  describe "hidden_resource?" do
    context "when resource is not moderated" do
      let(:resource) { create(:proposal) }

      it "returns false" do
        expect(subject.hidden_resource?).to be false
      end
    end

    context "when resource is moderated" do
      let(:resource) { create(:proposal, :moderated) }

      it "returns true" do
        expect(subject.hidden_resource?).to be true
      end
    end
  end
end
