# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::ProposalParticipantsMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }

  # Create a proposal (Proposals)
  # Give support to a proposal (Proposals)
  # Endorse (Proposals)
  let(:proposals_component) { create(:proposal_component, :published, participatory_space: participatory_space) }
  let(:proposal) { create(:proposal, :with_endorsements, published_at: day, component: proposals_component) }
  let(:proposal_votes) { create_list(:proposal_vote, 10, created_at: day, proposal: proposal) }
  let(:proposal_endorsements) { create_list(:proposal_endorsement, 5, created_at: day, proposal: proposal) }
  # TOTAL Participants for Proposals: 16 ( 1 proposal, 10 votes, 5 endorsements )
  let(:all) { proposal && proposal_votes && proposal_endorsements }

  context "when executing class" do
    before { all }

    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(16)
      expect(result[:quantity_users].count).to eq(16)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
