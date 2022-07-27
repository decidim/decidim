# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe DestroyProposal do
      describe "call" do
        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let(:current_user) { create(:user, organization:) }
        let(:other_user) { create(:user, organization:) }
        let!(:proposal) { create :proposal, component:, users: [current_user] }
        let(:proposal_draft) { create(:proposal, :draft, component:, users: [current_user]) }
        let!(:proposal_draft_other) { create :proposal, component:, users: [other_user] }

        it "broadcasts ok" do
          expect { described_class.call(proposal_draft, current_user) }.to broadcast(:ok)
          expect { proposal_draft.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "broadcasts invalid when the proposal is not a draft" do
          expect { described_class.call(proposal, current_user) }.to broadcast(:invalid)
        end

        it "broadcasts invalid when the proposal_draft is from another author" do
          expect { described_class.call(proposal_draft_other, current_user) }.to broadcast(:invalid)
        end
      end
    end
  end
end
