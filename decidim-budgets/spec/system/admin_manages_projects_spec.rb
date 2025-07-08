# frozen_string_literal: true

require "spec_helper"

describe "Admin manages projects" do
  include_context "when managing a component as an admin"
  let(:manifest_name) { "budgets" }
  let!(:budget) { create(:budget, component: current_component) }
  let!(:project) { create(:project, budget:) }
  let!(:destination_budget) { create(:budget, component: current_component) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  let!(:component) { create(:component, manifest:, participatory_space:, settings: { taxonomy_filters: taxonomy_filter_ids }) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within "tr", text: translated(budget.title) do
      find("button[data-component='dropdown']").click
      click_on "Manage projects"
    end
  end

  it_behaves_like "manage projects"
  it_behaves_like "import proposals to projects"
  it_behaves_like "export projects"

  describe "bulk actions" do
    let!(:project2) { create(:project, budget:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: another_taxonomy.parent) }
    let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: another_taxonomy_filter, taxonomy_item: another_taxonomy) }
    let(:taxonomy_filter_ids) { [taxonomy_filter.id, another_taxonomy_filter.id] }

    before do
      visit current_path
    end

    it "changes projects taxonomies" do
      find(".js-resource-id-#{project.id}").set(true)
      find_by_id("js-bulk-actions-button").click
      click_on "Change taxonomies"
      select decidim_sanitize_translated(taxonomy.name), from: "taxonomies_for_filter_#{taxonomy_filter.id}"
      select decidim_sanitize_translated(another_taxonomy.name), from: "taxonomies_for_filter_#{another_taxonomy_filter.id}"
      click_on "Change taxonomies"

      expect(page).to have_admin_callout "Projects successfully updated"
      expect(page).to have_admin_callout translated(taxonomy.name)
      expect(page).to have_admin_callout translated(another_taxonomy.name)
      expect(project.reload.taxonomies).to include(taxonomy)
      expect(project.taxonomies).to include(another_taxonomy)
      expect(project2.reload.taxonomies).to be_empty
    end

    it "selects projects to implementation" do
      within "tr[data-id='#{project.id}']" do
        expect(page).to have_content("No")
      end
      within "tr[data-id='#{project2.id}']" do
        expect(page).to have_content("No")
      end

      find_by_id("projects_bulk").set(true)
      find_by_id("js-bulk-actions-button").click
      click_on "Change selected"
      select "Select", from: "selected_value"
      click_on "Update"

      expect(page).to have_admin_callout "These projects were successfully selected for implementation"
      within "tr[data-id='#{project.id}']" do
        expect(page).to have_content("Yes")
      end
      within "tr[data-id='#{project2.id}']" do
        expect(page).to have_content("Yes")
      end
      expect(Decidim::Budgets::Project.find(project.id).selected_at).to eq(Time.zone.today)
      expect(Decidim::Budgets::Project.find(project2.id).selected_at).to eq(Time.zone.today)
    end

    describe "update projects budget" do
      let!(:another_component) { create(:budgets_component, organization:, participatory_space: current_component.participatory_space) }
      let!(:another_budget) { create(:budget, component: another_component) }

      it "shows all of the budgets within the participatory_space" do
        visit current_path
        find_by_id("projects_bulk").set(true)
        find_by_id("js-bulk-actions-button").click
        click_on "Change budget"
        options = ["Select budget", format_title(destination_budget), format_title(budget), format_title(another_budget)]
        expect(page).to have_select("reference_id", options:)
      end

      it "changes project budget" do
        find_by_id("projects_bulk").set(true)
        find_by_id("js-bulk-actions-button").click
        click_on "Change budget"
        select translated(destination_budget.title), from: "reference_id"
        click_on "Update project's budget"
        within_flash_messages do
          expect(page).to have_content("Projects successfully updated to the budget: #{translated(project.title)} and #{translated(project2.title)}")
        end
        expect(page).to have_no_css("tr[data-id='#{project.id}']")
        expect(page).to have_no_css("tr[data-id='#{project2.id}']")

        expect(project.reload.budget).to eq(destination_budget)
        expect(project2.reload.budget).to eq(destination_budget)
      end
    end

    describe "soft delete a projects" do
      let(:admin_resource_path) { current_path }
      let(:trash_path) { "#{admin_resource_path}/manage_trash" }
      let(:title) { { en: "My projects" } }
      let!(:budget) { create(:budget, component: current_component) }
      let!(:resource) { create(:project, budget:, title:) }

      it_behaves_like "manage soft deletable resource", "project"
      it_behaves_like "manage trashed resource", "project"
    end
  end

  private

  def format_title(budget)
    "     #{translated(budget.title)}"
  end
end
