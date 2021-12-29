# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::ResultProgressUpdatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.accountability.result_progress_updated" }
  let(:resource) { create(:result) }
  let(:proposal_component) do
    create(:component, manifest_name: "proposals", participatory_space: resource.component.participatory_space)
  end
  let(:proposal) { create :proposal, component: proposal_component, title: { en: "My super proposal" } }
  let(:extra) { { proposal_id: proposal.id, progress: 95 } }
  let(:proposal_path) { resource_locator(proposal).path }
  let(:proposal_title) { translated(proposal.title) }

  before do
    resource.link_resources([proposal], "included_proposals")
  end

  it_behaves_like "a simple event", proposal_text: true

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
      expect(subject.email_subject).to eq("An update to #{translated resource.title} progress")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to eq("You have received this notification because you are following \"#{proposal_title}\", and this proposal is included in the result \"#{translated resource.title}\". You can stop receiving notifications following the previous link.")
      expect(subject.email_outro).not_to include(proposal.title.to_s)
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The result \"#{translated resource.title}\", which includes the proposal \"#{proposal_title}\", is now 95% complete. You can see it from this page:")
      expect(subject.email_intro).not_to include(proposal.title.to_s)
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to eq("The result <a href=\"#{resource_path}\">#{resource_title}</a>, which includes the proposal <a href=\"#{proposal_path}\">#{proposal_title}</a>, is now 95% complete.")
    end
  end

  describe "resource_text" do
    it "outputs the localized result description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end
end
