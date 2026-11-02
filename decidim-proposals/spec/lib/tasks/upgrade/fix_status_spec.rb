# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_proposals:upgrade:fix_status", type: :task do
  let!(:component1) { create(:proposal_component, :with_amendments_enabled) }
  let!(:component2) { create(:proposal_component, :with_amendments_enabled) }

  context "when executing task" do
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal_status = proposal.proposal_status = Decidim::Proposals::ProposalStatus.where(component: component2).first
      proposal.update!(proposal_status:)
    end

    it "does not throw an exception" do
      expect { task.execute }.not_to raise_exception
    end
  end

  context "when status equivalent exists on proposal component" do
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal_status = proposal.proposal_status = Decidim::Proposals::ProposalStatus.where(component: component2).first
      proposal.update!(proposal_status:)
    end

    it "sets the status of the correct component" do
      Rake::Task[:"decidim_proposals:upgrade:fix_status"].reenable
      Rake::Task["decidim_proposals:upgrade:fix_status"].invoke
      proposal.reload
      expect(proposal.component.id).to eq(proposal.proposal_status.component.id)
    end
  end

  context "when the proposal has a custom status" do
    let!(:status) { create(:proposal_status, component: component2, token: :finished, title: { en: "Finished" }) }
    let(:proposal) { create(:proposal, :unpublished, component: component1) }

    before do
      proposal.update!(proposal_status: status)
    end

    it "removes the status" do
      Rake::Task[:"decidim_proposals:upgrade:fix_status"].reenable
      Rake::Task["decidim_proposals:upgrade:fix_status"].invoke
      proposal.reload
      expect(proposal.proposal_status).to be_nil
    end
  end
end
