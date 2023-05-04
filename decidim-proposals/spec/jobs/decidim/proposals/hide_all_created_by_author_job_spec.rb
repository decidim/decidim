# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::HideAllCreatedByAuthorJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:author) { create(:user, organization:) }
  let(:current_user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, organization:) }
  let(:proposal) { create(:proposal, component:, users: [author]) }
  let(:proposal2) { create(:proposal, component:) }
  let(:collaborative_drafts_component) { create(:proposal_component, :with_collaborative_drafts_enabled, organization:) }
  let(:authors) { create_list(:user, 5, organization:) }
  let(:collaborative_draft) { create(:collaborative_draft, component: collaborative_drafts_component, users: [author]) }
  let(:collaborative_draft2) { create(:collaborative_draft, component: collaborative_drafts_component) }

  let(:justification) { "This is a spam proposal" }
  let(:event_name) { "decidim.system.events.hide_user_created_content" }
  let(:arguments) { { author:, justification:, current_user: } }

  describe "queue" do
    it "is queued to user_report" do
      expect(subject.queue_name).to eq "user_report"
    end
  end

  context "with both resources" do
    describe "#perform" do
      it "hides all proposals created by an author" do
        expect(collaborative_draft2).not_to be_hidden
        expect(collaborative_draft).not_to be_hidden
        expect(proposal).not_to be_hidden
        expect(proposal2).not_to be_hidden
        described_class.perform_now(**arguments)
        expect(proposal.reload).to be_hidden
        expect(proposal2.reload).not_to be_hidden
        expect(collaborative_draft.reload).to be_hidden
        expect(collaborative_draft2.reload).not_to be_hidden
      end
    end

    describe "is fired by event" do
      it "hides the resources when the event is broadcasted" do
        expect(described_class).to receive(:perform_later).with(**arguments)
        ActiveSupport::Notifications.publish(event_name, arguments)
      end
    end
  end

  context "with proposals" do
    describe "#perform" do
      it "hides all proposals created by an author" do
        expect(proposal).not_to be_hidden
        expect(proposal2).not_to be_hidden
        described_class.perform_now(**arguments)
        expect(proposal.reload).to be_hidden
        expect(proposal2.reload).not_to be_hidden
      end
    end

    describe "is fired by event" do
      it "hides the resources when the event is broadcasted" do
        expect(described_class).to receive(:perform_later).with(**arguments)
        ActiveSupport::Notifications.publish(event_name, arguments)
      end
    end
  end

  context "with collaborative Draft" do
    describe "#perform" do
      it "hides all proposals created by an author" do
        expect(collaborative_draft2).not_to be_hidden
        expect(collaborative_draft).not_to be_hidden
        described_class.perform_now(**arguments)
        expect(collaborative_draft.reload).to be_hidden
        expect(collaborative_draft2.reload).not_to be_hidden
      end
    end

    describe "is fired by event" do
      it "hides the resources when the event is broadcasted" do
        expect(described_class).to receive(:perform_later).with(**arguments)
        ActiveSupport::Notifications.publish(event_name, arguments)
      end
    end
  end
end
