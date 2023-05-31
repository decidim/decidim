# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalNote do
      subject { proposal_note }

      let!(:organization) { create(:organization) }
      let!(:component) { create(:component, organization:, manifest_name: "proposals") }
      let!(:participatory_process) { create(:participatory_process, organization:) }
      let!(:author) { create(:user, :admin, organization:) }
      let!(:proposal) { create(:proposal, component:, users: [author]) }
      let!(:proposal_note) { build(:proposal_note, proposal:, author:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has an associated author" do
        expect(proposal_note.author).to be_a(Decidim::User)
      end

      it "has an associated proposal" do
        expect(proposal_note.proposal).to be_a(Decidim::Proposals::Proposal)
      end
    end
  end
end
