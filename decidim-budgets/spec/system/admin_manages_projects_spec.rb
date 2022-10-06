# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages projects", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: current_component }
  let!(:project) { create :project, budget: }

  include_context "when managing a component as an admin"

  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
  end

  it_behaves_like "manage projects"
  it_behaves_like "import proposals to projects"

  describe "bulk actions" do
    let!(:project2) { create(:project, budget:) }
    let!(:category) { create(:category, participatory_space: current_component.participatory_space) }
    let!(:scope) { create(:scope, organization: current_component.organization) }

    before do
      visit current_path
    end

    it "changes projects category" do
      find(".js-resource-id-#{project.id}").set(true)
      find("#js-bulk-actions-button").click
      click_button "Change category"
      select translated(category.name), from: "category_id"
      click_button "Update"
      expect(page).to have_css(".callout.success")
      within "tr[data-id='#{project.id}']" do
        expect(page).to have_content(translated(category.name))
      end
      expect(::Decidim::Budgets::Project.find(project.id).category).to eq(category)
      expect(::Decidim::Budgets::Project.find(project2.id).category).to be_nil
    end

    it "changes projects scope" do
      find(".js-resource-id-#{project.id}").set(true)
      find("#js-bulk-actions-button").click
      click_button "Change scope"
      scope_pick select_data_picker(:scope_id), scope
      click_button "Update"
      expect(page).to have_css(".callout.success")
      within "tr[data-id='#{project.id}']" do
        expect(page).to have_content(translated(scope.name))
      end
      expect(::Decidim::Budgets::Project.find(project.id).scope).to eq(scope)
      expect(::Decidim::Budgets::Project.find(project2.id).scope).to be_nil
    end

    it "selects projects to implementation" do
      find("#projects_bulk").set(true)
      find("#js-bulk-actions-button").click
      click_button "Change selected"
      select "Select", from: "selected_value"
      click_button "Update"
      expect(page).to have_css(".callout.success")
      within "tr[data-id='#{project.id}']" do
        expect(page).to have_content("Selected")
      end
      within "tr[data-id='#{project2.id}']" do
        expect(page).to have_content("Selected")
      end
      expect(::Decidim::Budgets::Project.find(project.id).selected_at).to eq(Time.zone.today)
      expect(::Decidim::Budgets::Project.find(project2.id).selected_at).to eq(Time.zone.today)
    end
  end
end
