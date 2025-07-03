# frozen_string_literal: true

require "spec_helper"

describe "Admin manages budgets" do
  let!(:budget) { create(:budget, component: current_component) }
  let(:manifest_name) { "budgets" }
  let(:attributes) { attributes_for(:budget) }

  include_context "when managing a component as an admin"
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage taxonomy filters in settings"

  describe "admin form" do
    before { click_on "New budget" }

    it_behaves_like "having a rich text editor", "new_budget", "content"
  end

  it "creates a new budget", versioning: true do
    click_on "New budget"

    within ".new_budget" do
      fill_in_i18n(:budget_title, "#budget-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:budget_description, "#budget-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in :budget_weight, with: 1
      fill_in :budget_total_budget, with: 100_000_00
    end

    click_on "Create budget"

    expect(page).to have_admin_callout("Budget successfully created.")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} budget")
  end

  describe "updating a budget", versioning: true do
    it "updates a budget" do
      within "tr", text: translated(budget.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_budget" do
        fill_in_i18n(:budget_title, "#budget-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n_editor(:budget_description, "#budget-description-tabs", **attributes[:description].except("machine_translations"))
      end

      click_on "Update budget"

      expect(page).to have_admin_callout("Budget successfully updated.")

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} budget")
    end
  end

  describe "previewing budgets" do
    it "links the budget correctly" do
      within "tr", text: translated(budget.title) do
        find("button[data-component='dropdown']").click
        preview_window = window_opened_by { click_on "Preview" }
        within_window preview_window do
          expect(page).to have_current_path(Decidim::EngineRouter.main_proxy(budget.component).budget_projects_path(budget))
        end
      end
    end
  end

  describe "soft deleting a budget" do
    it "moves to the trash a budget" do
      within "tr", text: translated(budget.title) do
        accept_confirm do
          find("button[data-component='dropdown']").click
          click_on "Soft delete"
        end
      end

      expect(page).to have_admin_callout("Budget successfully deleted.")

      within "table" do
        expect(page).to have_no_content(translated(budget.title))
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

  describe "soft delete a budget" do
    let(:admin_resource_path) { current_path }
    let(:trash_path) { "#{admin_resource_path}/budgets/manage_trash" }
    let(:title) { { en: "My budget" } }
    let!(:resource) { create(:budget, title:, component: current_component) }

    it_behaves_like "manage soft deletable resource", "budget"
    it_behaves_like "manage trashed resource", "budget"
  end
end
