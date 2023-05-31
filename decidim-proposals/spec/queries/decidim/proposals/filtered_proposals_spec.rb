# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::FilteredProposals do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:another_component) { create(:proposal_component, participatory_space: participatory_process) }

  let(:proposals) { create_list(:proposal, 3, component:) }
  let(:old_proposals) { create_list(:proposal, 3, component:, created_at: 10.days.ago) }
  let(:another_proposals) { create_list(:proposal, 3, component: another_component) }

  it "returns proposals included in a collection of components" do
    expect(described_class.for([component, another_component])).to match_array proposals.concat(old_proposals, another_proposals)
  end

  it "returns proposals created in a date range" do
    expect(described_class.for([component, another_component], 2.weeks.ago, 1.week.ago)).to match_array old_proposals
  end
end
