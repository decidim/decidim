# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ImportProposalsJob do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:origin_component) { create(:proposal_component, participatory_space:) }
  let(:target_component) { create(:proposal_component, participatory_space:) }
  let(:current_user) { create(:user, :admin, organization:) }

  let!(:accepted_proposal) { create(:proposal, :accepted, component: origin_component, title: "Accepted proposal") }
  let!(:rejected_proposal) { create(:proposal, :rejected, component: origin_component, title: "Rejected proposal") }

  let(:payload) do
    {
      "origin_component_id" => origin_component.id,
      "current_component_id" => target_component.id,
      "current_user_id" => current_user.id,
      "current_organization_id" => organization.id,
      "keep_authors" => false,
      "keep_answers" => false
    }
  end

  def imported_proposals
    Decidim::Proposals::Proposal.where(component: target_component)
  end

  def imported_titles
    imported_proposals.map { |proposal| proposal.title["en"] }
  end

  it "only copies the proposals with the given statuses" do
    described_class.perform_now(payload.merge("statuses" => ["accepted"]))

    expect(imported_titles).to eq(["Accepted proposal"])
  end

  context "with the legacy states key" do
    it "only copies the proposals with the given statuses" do
      described_class.perform_now(payload.merge("states" => ["accepted"]))

      expect(imported_titles).to eq(["Accepted proposal"])
    end
  end
end
