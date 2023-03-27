# frozen_string_literal: true

require "spec_helper"

describe "Admin imports projects to accountability", type: :system do
  let(:manifest_name) { "accountability" }
  let(:resource_controller) { Decidim::Accountability::Admin::ImportResultsController }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, organization:) }
  let(:accountability_component_published_at) { nil }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  context "when there are no budgets components to import" do
    before do
      find("span", text: "Import").click
      click_on "Import projects to results"
    end

    it "shows no component to select" do
      expect(page).to have_content t("projects_import.new.no_components", scope: "decidim.accountability.admin")
    end
  end

  describe "import" do
    let!(:result_sets) { create_list(:result, 5, created_at: Time.current, component:) }

    before do
      visit current_path
      find("span", text: "Import").click
    end

    it "link exists only in main list" do
      expect(page).to have_content("Import projects to results")
      page.find(".table-list tr:nth-child(1) td:nth-child(2)").click
      expect(page).not_to have_content(t("decidim.accountability.actions.import"))
    end
  end

  context "when there are budgets components" do
    let!(:budget_component) { create(:component, manifest_name: "budgets", participatory_space:) }
    let!(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }

    before do
      find("span", text: "Import").click
      click_on "Import projects to results"
    end

    context "when there are no projects" do
      before do
        visit current_path
        find("#result_import_projects_origin_component_id").find("option[value='#{budget_component.id}']").select_option
        find("#result_import_projects_import_all_selected_projects").set(true)
      end

      it "shows error message" do
        expect(page).to have_content "There are no selected projects in this origin component"
        click_on "Import"
        expect(page).to have_content "There was a problem importing the projects into results, please follow the instructions carefully and make sure you have selected projects for implementation."
      end
    end

    context "when there are some projects" do
      let!(:selected_set) { create_list(:project, 3, budget:, selected_at: Time.current) }

      before do
        visit current_path
        find("#result_import_projects_origin_component_id").find("option[value='#{budget_component.id}']").select_option
        find("#result_import_projects_import_all_selected_projects").set(true)
      end

      it "imports the projects into results" do
        expect(page).to have_content("3 selected projects will be imported")
        click_on "Import"
        expect(page).to have_content "3 projects queued to be imported. You will be notified by email, once completed"
      end
    end
  end
end
