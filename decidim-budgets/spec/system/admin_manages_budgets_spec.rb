# frozen_string_literal: true

require "spec_helper"

describe "Admin manages budgets", type: :system do
  let(:budget) { create(:budget, component: current_component) }
  let(:manifest_name) { "budgets" }

  include_context "when managing a component as an admin"
  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "admin form" do
    before { click_on "New budget" }

    it_behaves_like "having a rich text editor", "new_budget", "content"
  end

  it "creates a new budget" do
    click_link "New budget"

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
      select translated(scope.name), from: :budget_decidim_scope_id
    end

    click_button "Create budget"

    expect(page).to have_admin_callout("Budget successfully created.")

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
      end

      click_button "Update budget"

      expect(page).to have_admin_callout("Budget successfully updated.")

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

      expect(page).to have_admin_callout("Budget successfully deleted.")

      within "table" do
        expect(page).not_to have_content(translated(budget.title))
      end
    end

    context "when the budget has projects" do
      let!(:budget) { create(:budget, :with_projects, component: current_component) }

      it "cannot delete the budget" do
        within find("tr", text: translated(budget.title)) do
          expect(page).not_to have_selector(".action-icon--remove")
        end
      end
    end
  end

  describe "component page shows finished and pending orders of all budgets" do
    context "when component has many budgets with orders" do
      let(:budget2) { create(:budget, :with_projects, component: current_component) }
      let(:project) { create(:project, budget:, budget_amount: 90_000_000) }
      let(:project2) { create(:project, budget: budget2, budget_amount: 95_000_000) }
      let(:user2) { create(:user, :confirmed, organization:) }
      let(:user3) { create(:user, :confirmed, organization:) }

      # User has one finished and pending order
      let!(:finished_order) do
        order = create(:order, user:, budget:)
        order.projects << project
        order.checked_out_at = Time.current
        order.save!
        order
      end
      let!(:pending_order) do
        order = create(:order, user:, budget: budget2)
        order.projects << project2
        order.save!
        order
      end

      # User2 has two finished orders
      let!(:finished_order2) do
        order = create(:order, user: user2, budget:)
        order.projects << project
        order.checked_out_at = Time.current
        order.save!
        order
      end
      let!(:finished_order3) do
        order = create(:order, user: user2, budget: budget2)
        order.projects << project2
        order.checked_out_at = Time.current
        order.save!
        order
      end

      # User3 has one finished order
      let!(:finished_order4) do
        order = create(:order, user: user3, budget: budget2)
        order.projects << project2
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "shows finished and pending orders" do
        visit current_path
        within find_all(".card-divider").last do
          expect(page).to have_content("Finished votes: 4")
          expect(page).to have_content("Pending votes: 1")
        end
      end

      it "shows count of users with finished and pending orders" do
        visit current_path
        within find_all(".card-divider").last do
          expect(page).to have_content("Users with finished votes: 3")
          expect(page).to have_content("Users with pending votes: 1")
        end
      end
    end
  end
end
