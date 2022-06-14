# frozen_string_literal: true

require "spec_helper"

describe "Explore Budgets", :slow, type: :system do
  include ActionView::Helpers::NumberHelper

  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let!(:component) do
    create(:budgets_component,
           :with_vote_threshold_percent,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  context "with only one budget" do
    let!(:budgets) { create_list(:budget, 1, component: component) }

    it "redirects to the only budget details" do
      visit_component

      expect(page).to have_content("More information")
    end
  end

  context "with many budgets" do
    let!(:budgets) do
      1.upto(6).to_a.map { |x| create(:budget, component: component, weight: x, total_budget: x * 10_000_000, description: { en: "This is budget #{x}" }) }
    end

    before do
      visit_component
    end

    it "lists all the budgets" do
      expect(page).to have_selector(".card--list__item", count: 6)

      budgets.each do |budget|
        expect(page).to have_content(translated(budget.title))
        expect(page).to have_content(number_to_currency(budget.total_budget, unit: Decidim.currency_unit, precision: 0))
      end
    end

    describe "budget list item" do
      let(:budget) { budgets.first }
      let(:item) { page.find(".budget-list .card--list__item:first-child", match: :first) }
      let!(:projects) { create_list(:project, 3, budget: budget, budget_amount: 10_000_000) }

      before do
        login_as user, scope: :user
      end

      it "has a clickable title" do
        expect(item).to have_link(translated(budget.title), href: budget_path(budget))
      end

      context "when an item is bookmarked" do
        let!(:order) { create(:order, user: user, budget: budget) }
        let!(:line_item) { create(:line_item, order: order, project: projects.first) }

        it "shows the bookmark icon" do
          visit_component

          expect(item).to have_selector(".budget-list__icon span.warning")
          expect(item).to have_link("Finish voting", href: budget_path(budget))
        end
      end

      context "when an item is voted" do
        let(:item) { page.find("#voted-budgets .card--list__item:first-child") }

        let!(:order) do
          order = create(:order, user: user, budget: budget)
          order.projects = [projects.first]
          order.checked_out_at = Time.current
          order.save!
          order
        end

        it "shows the check icon" do
          visit_component

          expect(item).to have_selector(".budget-list__icon span.success")
          expect(item).to have_link("See projects", href: budget_path(budget))
        end
      end
    end
  end

  context "when directly accessing from URL with an invalid budget id" do
    it_behaves_like "a 404 page" do
      let(:target_path) { Decidim::EngineRouter.main_proxy(component).budget_path(99_999_999) }
    end
  end

  def budget_path(budget)
    Decidim::EngineRouter.main_proxy(component).budget_path(budget.id)
  end
end
