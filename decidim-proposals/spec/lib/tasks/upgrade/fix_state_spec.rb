# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_proposals:upgrade:fix_state", type: :task do
  let!(:component1) { create(:proposal_component, :with_amendments_enabled) }
  let!(:component2) { create(:proposal_component, :with_amendments_enabled) }

  context "when executing task" do
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal_state = proposal.proposal_state = Decidim::Proposals::ProposalState.where(component: component2).first
      proposal.update!(proposal_state: proposal_state)
    end

    it "does not throw an exception" do
      expect { task.execute }.not_to raise_exception
    end
  end

  context "when state equivalent exists on proposal component" do
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal_state = proposal.proposal_state = Decidim::Proposals::ProposalState.where(component: component2).first
      proposal.update!(proposal_state: proposal_state)
    end

    it "sets the state of the correct component" do
      Rake::Task[:"decidim_proposals:upgrade:fix_state"].reenable
      Rake::Task["decidim_proposals:upgrade:fix_state"].invoke
      proposal.reload
      expect(proposal.component.id).to eq(proposal.proposal_state.component.id)
    end
  end

  context "when the proposal has a custom state" do
    let!(:state) { create(:proposal_state, component: component2, token: :finished, title: { en: "Finished" }) }
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal.update!(proposal_state: state)
    end

    it "removes the state" do
      Rake::Task[:"decidim_proposals:upgrade:fix_state"].reenable
      Rake::Task["decidim_proposals:upgrade:fix_state"].invoke
      proposal.reload
      expect(proposal.proposal_state).to be_nil
    end
  end
end
