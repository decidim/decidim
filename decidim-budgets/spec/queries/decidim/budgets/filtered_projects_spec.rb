# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::FilteredProjects do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:budget_component, participatory_space: participatory_process) }
  let(:another_component) { create(:budget_component, participatory_space: participatory_process) }

  let(:projects) { create_list(:project, 3, component: component) }
  let(:old_projects) { create_list(:project, 3, component: component, created_at: 10.days.ago) }
  let(:another_projects) { create_list(:project, 3, component: another_component) }

  it "returns projects included in a collection of components" do
    expect(described_class.for([component, another_component])).to match_array projects.concat(old_projects, another_projects)
  end

  it "returns projects created in a date range" do
    expect(described_class.for([component, another_component], 2.weeks.ago, 1.week.ago)).to match_array old_projects
  end
end
