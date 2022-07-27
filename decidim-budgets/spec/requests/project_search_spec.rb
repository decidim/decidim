# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Project search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :budgets_component }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }
  let(:resource_params) { { budget: } }

  let(:budget) { create(:budget, component:) }
  let(:budget2) { create(:budget, component:) }
  let!(:project1) do
    create(
      :project,
      :selected,
      budget:,
      scope: create(:scope, organization:),
      category: create(:category, participatory_space:)
    )
  end
  let!(:project2) do
    create(
      :project,
      :selected,
      budget:,
      scope: create(:scope, organization:),
      category: create(:category, participatory_space:)
    )
  end
  let!(:project3) do
    create(
      :project,
      budget:,
      scope: create(:scope, organization:),
      category: create(:category, participatory_space:)
    )
  end
  let!(:project4) { create(:project, budget: budget2) }
  let!(:project5) { create(:project, budget: budget2) }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget) }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :project
  it_behaves_like "a resource search with scopes", :project
  it_behaves_like "a resource search with categories", :project

  it "displays all projects within the budget without any filters" do
    expect(subject).to include(translated(project1.title))
    expect(subject).to include(translated(project2.title))
    expect(subject).to include(translated(project3.title))
    expect(subject).not_to include(translated(project4.title))
    expect(subject).not_to include(translated(project5.title))
  end

  context "when searching by status" do
    let(:filter_params) { { with_any_status: status } }

    context "with the all scope" do
      let(:status) { ["all"] }

      it "displays all projects" do
        expect(subject).to include(translated(project1.title))
        expect(subject).to include(translated(project2.title))
        expect(subject).to include(translated(project3.title))
      end
    end

    context "and the status is selected" do
      let(:status) { ["selected"] }

      it "displays the selected projects" do
        expect(subject).to include(translated(project1.title))
        expect(subject).to include(translated(project2.title))
        expect(subject).not_to include(translated(project3.title))
      end
    end

    context "and the status is not selected" do
      let(:status) { ["not_selected"] }

      it "displays the selected projects" do
        expect(subject).not_to include(translated(project1.title))
        expect(subject).not_to include(translated(project2.title))
        expect(subject).to include(translated(project3.title))
      end
    end
  end
end
