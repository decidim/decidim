# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::DiffRenderer, versioning: true do
  let!(:proposal) { create(:proposal) }
  let(:version) { proposal.versions.last }
  let(:state) { Decidim::Proposals::ProposalState.where(component: proposal.component, title: { en: "Rejected" }).last }

  before do
    Decidim.traceability.update!(
      proposal,
      "test suite",
      title: {
        en: "Only changes in English"
      },
      body: {
        ca: "<p>HTML description</p>"
      },
      decidim_proposals_proposal_state_id: state.id
    )
  end

  describe "#diff" do
    subject { described_class.new(version).diff }

    it "calculates the fields that have changed" do
      expect(subject.keys)
        .to contain_exactly(:title, :body, :decidim_proposals_proposal_state_id)
    end

    it "displays the state" do
      expect(subject[:decidim_proposals_proposal_state_id][:new_value]).to eq("Rejected")
    end
  end
end
