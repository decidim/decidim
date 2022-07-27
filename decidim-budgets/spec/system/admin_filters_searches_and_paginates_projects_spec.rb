# frozen_string_literal: true

require "spec_helper"

describe "Admin filters, searches, and paginates projects", type: :system do
  include_context "when managing a component as an admin"
  include_context "with filterable context"

  let(:manifest_name) { "budgets" }
  let(:resource_controller) { Decidim::Budgets::Admin::ProjectsController }
  let!(:budget) { create(:budget, component: current_component) }

  before do
    visit_component_admin
    find("a[title='Manage projects']").click
  end

  context "when filtering by scope" do
    let!(:scope1) { create(:scope, organization: component.organization, name: { "en" => "Scope1" }) }
    let!(:scope2) { create(:scope, organization: component.organization, name: { "en" => "Scope2" }) }
    let!(:project_with_scope1) { create(:project, budget:, scope: scope1) }
    let!(:project_with_scope2) { create(:project, budget:, scope: scope2) }
    let(:project_with_scope1_title) { translated(project_with_scope1.title) }
    let(:project_with_scope2_title) { translated(project_with_scope2.title) }

    before { visit current_path }

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { project_with_scope1_title }
      let(:not_in_filter) { project_with_scope2_title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { project_with_scope2_title }
      let(:not_in_filter) { project_with_scope1_title }
    end
  end

  context "when filtering by category" do
    let!(:category1) { create(:category, participatory_space:, name: { "en" => "Category1" }) }
    let!(:category2) { create(:category, participatory_space:, name: { "en" => "Category2" }) }
    let!(:project_with_category1) { create(:project, budget:, category: category1) }
    let!(:project_with_category2) { create(:project, budget:, category: category2) }
    let(:project_with_category1_title) { translated(project_with_category1.title) }
    let(:project_with_category2_title) { translated(project_with_category2.title) }

    before { visit current_path }

    it_behaves_like "a filtered collection", options: "Category", filter: "Category1" do
      let(:in_filter) { project_with_category1_title }
      let(:not_in_filter) { project_with_category2_title }
    end

    it_behaves_like "a filtered collection", options: "Category", filter: "Category2" do
      let(:in_filter) { project_with_category2_title }
      let(:not_in_filter) { project_with_category1_title }
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
