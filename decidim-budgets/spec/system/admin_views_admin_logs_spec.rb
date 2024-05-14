# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "budgets" }
  let!(:budget) { create(:budget, component: current_component) }

  include_context "when managing a component as an admin"

  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "project" do
    let!(:project) { create(:project, budget_amount: 70_000_000, budget:) }
    let(:attributes) { attributes_for(:project) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit_component_admin

      within "tr", text: translated(budget.title) do
        page.find(".action-icon--edit-projects").click
      end
    end

    it "creates a new project", versioning: true do
      within ".bulk-actions-budgets" do
        click_on "New project"
      end

      within ".new_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :project_description,
          "#project-description-tabs",
          **attributes[:description].except("machine_translations")
        )
        fill_in :project_budget_amount, with: 22_000_000

        select translated(scope.name), from: :project_decidim_scope_id
        select translated(category.name), from: :project_decidim_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a project", versioning: true do
      within "tr", text: translated(project.title) do
        click_on "Edit"
      end

      within ".edit_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          **attributes[:title].except("machine_translations")
        )
        fill_in_i18n_editor(
          :project_description,
          "#project-description-tabs",
          **attributes[:description].except("machine_translations")
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end

  describe "budgets" do
    let(:attributes) { attributes_for(:budget) }

    it "creates a new budget", versioning: true do
      click_on "New budget"

      within ".new_budget" do
        fill_in_i18n(:budget_title, "#budget-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:budget_description, "#budget-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in :budget_weight, with: 1
        fill_in :budget_total_budget, with: 100_000_00
        select translated(scope.name), from: :budget_decidim_scope_id
      end

      click_on "Create budget"

      expect(page).to have_admin_callout("Budget successfully created.")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a budget", versioning: true do
      within "tr", text: translated(budget.title) do
        page.find(".action-icon--edit").click
      end

      within ".edit_budget" do
        fill_in_i18n(:budget_title, "#budget-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:budget_description, "#budget-description-tabs", **attributes[:description].except("machine_translations"))
      end

      click_on "Update budget"

      expect(page).to have_admin_callout("Budget successfully updated.")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
