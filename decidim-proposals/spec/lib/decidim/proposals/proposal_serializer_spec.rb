# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      include_context "with a proposal"

      it_behaves_like "a proposal serializer"

      it_behaves_like "a proposal serializer with author"

      describe "when the proposal votes are hidden" do
        before do
          component.step_settings = { component.participatory_space.active_step.id => { votes_hidden: true } }
          component.save!
        end

        it "includes the votes count for the admin" do
          expect(serialized).to include(votes: proposal.proposal_votes_count)
        end
      end
    end
  end
end
