# frozen_string_literal: true
require "spec_helper"

describe Decidim::Results::FilteredResults do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:feature) { create(:result_feature, participatory_process: participatory_process) }
  let(:another_feature) { create(:result_feature, participatory_process: participatory_process) }

  let(:results) { create_list(:result, 3, feature: feature) }
  let(:old_results) { create_list(:result, 3, feature: feature, created_at: 10.days.ago) }
  let(:another_results) { create_list(:result, 3, feature: another_feature) }

  it "returns results included in a collection of features" do
    expect(Decidim::Results::FilteredResults.for([feature, another_feature])).to match_array results.concat(old_results, another_results)
  end

  it "returns results created in a date range" do
    expect(Decidim::Results::FilteredResults.for([feature, another_feature], 2.weeks.ago, 1.week.ago)).to match_array old_results
  end
end
