# frozen_string_literal: true

require "spec_helper"

describe "Admin filters, searches, and paginates projects" do
  include_context "when managing a component as an admin"
  include_context "with filterable context"

  let(:manifest_name) { "budgets" }
  let(:resource_controller) { Decidim::Budgets::Admin::ProjectsController }
  let!(:budget) { create(:budget, component: current_component) }

  before do
    visit_component_admin
    find("a[title='Manage projects']").click
  end

  context "when filtering by taxonomy" do
    let!(:taxonomy1) { create(:taxonomy, :with_parent, organization: component.organization, name: { "en" => "Taxonomy1" }) }
    let!(:taxonomy2) { create(:taxonomy, :with_parent, organization: component.organization, name: { "en" => "Taxonomy2" }) }
    let!(:project_with_taxonomy1) { create(:project, budget:, taxonomies: [taxonomy1]) }
    let!(:project_with_taxonomy2) { create(:project, budget:, taxonomies: [taxonomy2]) }
    let(:project_with_taxonomy1_title) { translated(project_with_taxonomy1.title) }
    let(:project_with_taxonomy2_title) { translated(project_with_taxonomy2.title) }

    before { visit current_path }

    it_behaves_like "a filtered collection", options: "Taxonomy", filter: "Taxonomy1" do
      let(:in_filter) { project_with_taxonomy1_title }
      let(:not_in_filter) { project_with_taxonomy2_title }
    end

    it_behaves_like "a filtered collection", options: "Taxonomy", filter: "Taxonomy2" do
      let(:in_filter) { project_with_taxonomy2_title }
      let(:not_in_filter) { project_with_taxonomy1_title }
    end
  end

  context "when filtering by selected" do
    let!(:project_with_status1) { create(:project, budget:, selected_at: Time.current) }
    let!(:project_with_status2) { create(:project, budget:, selected_at: nil) }
    let(:project_with_status1_title) { translated(project_with_status1.title) }
    let(:project_with_status2_title) { translated(project_with_status2.title) }

    before { visit current_path }

    it_behaves_like "a filtered collection", options: "Selected", filter: "Selected for implementation" do
      let(:in_filter) { project_with_status1_title }
      let(:not_in_filter) { project_with_status2_title }
    end

    it_behaves_like "a filtered collection", options: "Selected", filter: "Not selected for implementation" do
      let(:in_filter) { project_with_status2_title }
      let(:not_in_filter) { project_with_status1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:project1) { create(:project, budget:) }
    let!(:project2) { create(:project, budget:) }
    let!(:project1_title) { translated(project1.title) }
    let!(:project2_title) { translated(project2.title) }

    before { visit current_path }

    it "can be searched by ID" do
      search_by_text(project1.id)

      expect(page).to have_content(project1_title)
    end

    it "can be searched by title" do
      search_by_text(project2_title)

      expect(page).to have_content(project2_title)
    end
  end

  context "when listing projects" do
    before { visit current_path }

    it_behaves_like "paginating a collection" do
      let!(:collection) { create_list(:project, 50, budget:) }
    end
  end
end
