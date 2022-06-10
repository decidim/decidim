# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::ProposalMentionedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.proposals.proposal_mentioned" }
  let(:organization) { create :organization }
  let(:author) { create :user, organization: organization }

  let(:source_proposal) { create :proposal, component: create(:proposal_component, organization: organization), title: "Proposal A" }
  let(:mentioned_proposal) { create :proposal, component: create(:proposal_component, organization: organization), title: "It's proposal B" }
  let(:resource) { source_proposal }
  let(:extra) do
    {
      mentioned_proposal_id: mentioned_proposal.id
    }
  end

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
      expect(subject.email_subject).to eq("Your proposal \"#{decidim_sanitize(translated(mentioned_proposal.title))}\" has been mentioned")
    end
  end

  context "with content" do
    let(:content) do
      "Your proposal \"#{decidim_html_escape(translated(mentioned_proposal.title))}\" has been mentioned " \
        "<a href=\"#{resource_url}\">in this space</a> in the comments."
    end

    describe "email_intro" do
      let(:resource_url) { resource_locator(source_proposal).url }

      it "is generated correctly" do
        expect(subject.email_intro).to eq(content)
      end
    end

    describe "notification_title" do
      let(:resource_url) { resource_locator(source_proposal).path }

      it "is generated correctly" do
        expect(subject.notification_title).to include(content)
      end
    end
  end
end
