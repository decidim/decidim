# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::ProposalParticipantsMetricMeasure do
  let(:day) { Time.zone.yesterday }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

  let(:proposals_component) { create(:proposal_component, :published, participatory_space:) }
  let!(:proposal) { create(:proposal, :with_endorsements, published_at: day, component: proposals_component) }
  let!(:old_proposal) { create(:proposal, :with_endorsements, published_at: day - 1.week, component: proposals_component) }
  let!(:proposal_votes) { create_list(:proposal_vote, 10, created_at: day, proposal:) }
  let!(:old_proposal_votes) { create_list(:proposal_vote, 5, created_at: day - 1.week, proposal: old_proposal) }
  let!(:proposal_endorsements) do
    5.times.collect do
      create(:endorsement, created_at: day, resource: proposal, author: build(:user, organization:))
    end
  end
  # TOTAL Participants for Proposals:
  #  Cumulative: 22 ( 2 proposal, 15 votes, 5 endorsements )
  #  Quantity: 16 ( 1 proposal, 10 votes, 5 endorsements )

  context "when executing class" do
    it "fails to create object with an invalid resource" do
      manager = described_class.new(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.new(day, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(22)
      expect(result[:quantity_users].count).to eq(16)
    end

    it "does not found any result for past days" do
      result = described_class.new(day - 1.month, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
