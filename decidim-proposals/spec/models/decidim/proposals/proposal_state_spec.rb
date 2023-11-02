# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalState do
      subject { proposal_state }

      let(:component) { build(:proposal_component) }
      let(:organization) { component.participatory_space.organization }
      let(:proposal_state) { create(:proposal_state, component:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      describe "system" do
        let(:proposal_state) { create(:proposal_state, :accepted, component:) }

        it "prevents deletion" do
          expect { proposal_state.destroy }.not_to change { Decidim::Proposals::ProposalState.count }
        end
      end
    end
  end
end
