# frozen_string_literal: true

require "spec_helper"

describe "Admin manages budgets", type: :system do
  let(:budget) { create :budget, component: current_component }
  let(:manifest_name) { "budgets" }

  include_context "when managing a component as an admin"
  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "admin form" do
    before { click_on "New Budget" }

    it_behaves_like "having a rich text editor", "new_budget", "full"
  end

  it "creates a new budget" do
    within ".card-title" do
      page.find(".button.button--title").click
    end

    within ".new_budget" do
      fill_in_i18n(
        :budget_title,
        "#budget-title-tabs",
        en: "My Budget",
        es: "Mi Presupuesto",
        ca: "El meu Pressupost"
      )
      fill_in_i18n_editor(
        :budget_description,
        "#budget-description-tabs",
        en: "Long description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in :budget_weight, with: 1
      fill_in :budget_total_budget, with: 100_000_00
    end

    within ".new_budget" do
      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My Budget")
    end
  end

  describe "updating a budget" do
    it "updates a budget" do
      within find("tr", text: translated(budget.title)) do
        page.find(".action-icon--edit").click
      end

      within ".edit_budget" do
        fill_in_i18n(
          :budget_title,
          "#budget-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new title")
      end
    end
  end

  describe "previewing budgets" do
    it "links the budget correctly" do
      link = find("a[title=Preview]")
      expect(link[:href]).to include(resource_locator(budget).path)
    end
  end

  describe "deleting a budget" do
    it "deletes a budget" do
      within find("tr", text: translated(budget.title)) do
        accept_confirm do
          page.find(".action-icon--remove").click
        end
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(budget.title))
      end
    end

    context "when the budget has projects" do
      let!(:budget) { create(:budget, :with_projects, component: current_component) }

      xit "cannot delete the budget" do
        within find("tr", text: translated(budget.title)) do
          expect(page).to have_no_selector(".action-icon--remove")
        end
      end
    end
  end
end
