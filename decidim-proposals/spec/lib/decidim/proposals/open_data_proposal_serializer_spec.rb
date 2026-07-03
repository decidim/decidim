# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe OpenDataProposalSerializer do
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

        it "it does not include the votes count" do
          expect(serialized).to include(votes: nil)
        end
      end
    end
  end
end
