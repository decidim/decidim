# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::FilteredProposals do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:feature) { create(:proposal_feature, participatory_space: participatory_process) }
  let(:another_feature) { create(:proposal_feature, participatory_space: participatory_process) }

  let(:proposals) { create_list(:proposal, 3, feature: feature) }
  let(:old_proposals) { create_list(:proposal, 3, feature: feature, created_at: 10.days.ago) }
  let(:another_proposals) { create_list(:proposal, 3, feature: another_feature) }

  it "returns proposals included in a collection of features" do
    expect(described_class.for([feature, another_feature])).to match_array proposals.concat(old_proposals, another_proposals)
  end

  it "returns proposals created in a date range" do
    expect(described_class.for([feature, another_feature], 2.weeks.ago, 1.week.ago)).to match_array old_proposals
  end
end
