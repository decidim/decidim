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
    let(:root_taxonomy1) { create(:taxonomy, organization: component.organization, name: { "en" => "Root1" }) }
    let(:root_taxonomy2) { create(:taxonomy, organization: component.organization, name: { "en" => "Root2" }) }
    let!(:taxonomy1) { create(:taxonomy, parent: root_taxonomy1, organization: component.organization, name: { "en" => "Taxonomy1" }) }
    let!(:taxonomy2) { create(:taxonomy, parent: root_taxonomy2, organization: component.organization, name: { "en" => "Taxonomy2" }) }
    let(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy: root_taxonomy1, space_manifest: component.participatory_space.manifest.name) }
    let(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy: root_taxonomy2, space_manifest: component.participatory_space.manifest.name) }
    let!(:taxonomy_filter_item1) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy_filter1, taxonomy_item: taxonomy1) }
    let!(:taxonomy_filter_item2) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy_filter2, taxonomy_item: taxonomy2) }
    let!(:project_with_taxonomy1) { create(:project, budget:, taxonomies: [taxonomy1]) }
    let!(:project_with_taxonomy2) { create(:project, budget:, taxonomies: [taxonomy2]) }
    let(:project_with_taxonomy1_title) { translated(project_with_taxonomy1.title) }
    let(:project_with_taxonomy2_title) { translated(project_with_taxonomy2.title) }

    before do
      component.update!(settings: { taxonomy_filters: [taxonomy_filter1.id, taxonomy_filter2.id] })
      visit current_path
    end

    it_behaves_like "a sub-filtered collection", option1: "In taxonomy", option2: "Root1", filter: "Taxonomy1" do
      let(:in_filter) { project_with_taxonomy1_title }
      let(:not_in_filter) { project_with_taxonomy2_title }
    end

    it_behaves_like "a sub-filtered collection", option1: "In taxonomy", option2: "Root2", filter: "Taxonomy2" do
      let(:in_filter) { project_with_taxonomy2_title }
      let(:not_in_filter) { project_with_taxonomy1_title }
    end

    it_behaves_like "a filtered collection", options: "In taxonomy or children", filter: "Root1" do
      let(:in_filter) { project_with_taxonomy1_title }
      let(:not_in_filter) { project_with_taxonomy2_title }
    end

    it_behaves_like "a filtered collection", options: "In taxonomy or children", filter: "Root2" do
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
