# frozen_string_literal: true
require "spec_helper"

describe Decidim::Budgets::FilteredProjects do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:feature) { create(:budget_feature, participatory_process: participatory_process) }
  let(:another_feature) { create(:budget_feature, participatory_process: participatory_process) }

  let(:projects) { create_list(:project, 3, feature: feature) }
  let(:old_projects) { create_list(:project, 3, feature: feature, created_at: 10.days.ago) }
  let(:another_projects) { create_list(:project, 3, feature: another_feature) }

  it "returns projects included in a collection of features" do
    expect(Decidim::Budgets::FilteredProjects.for([feature, another_feature])).to match_array projects.concat(old_projects, another_projects)
  end

  it "returns projects created in a date range" do
    expect(Decidim::Budgets::FilteredProjects.for([feature, another_feature], 2.weeks.ago, 1.week.ago)).to match_array old_projects
  end
end
