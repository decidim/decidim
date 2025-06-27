# frozen_string_literal: true

require "spec_helper"

describe "Explore Budgets", :slow do
  include ActionView::Helpers::NumberHelper

  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let!(:component) do
    create(:budgets_component,
           :with_vote_threshold_percent,
           manifest:,
           participatory_space: participatory_process)
  end

  context "with no budgets" do
    it "shows an empty page with a message" do
      visit_component

      expect(page).to have_content("There are no budgets yet")
    end
  end

  context "with only one budget" do
    let!(:budgets) { create_list(:budget, 1, component:) }

    before do
      visit_component
    end

    it "shows the component name in the sidebar" do
      within("aside") do
        expect(page).to have_content(translated(component.name))
      end
    end

    it "list the budget" do
      expect(page).to have_css(".card--list__item", count: 1)

      budgets.each do |budget|
        expect(page).to have_content(translated(budget.title))
        expect(page).to have_content(number_to_currency(budget.total_budget, unit: Decidim.currency_unit, precision: 0))
      end
      expect(page).to have_no_content("Remove vote")
      expect(page).to have_content("0 projects")
    end
  end

  context "with many budgets" do
    let!(:budgets) do
      1.upto(6).to_a.map { |x| create(:budget, component:, weight: x, total_budget: x * 10_000_000, description: { en: "This is budget #{x}" }) }
    end

    before do
      visit_component
    end

    it "shows the component name in the sidebar" do
      within("aside") do
        expect(page).to have_content(translated(component.name))
      end
    end

    it "lists all the budgets" do
      expect(page).to have_css(".card--list__item", count: 6)

      budgets.each do |budget|
        expect(page).to have_content(translated(budget.title))
        expect(page).to have_content(number_to_currency(budget.total_budget, unit: Decidim.currency_unit, precision: 0))
      end
      expect(page).to have_no_content("Remove vote")
      expect(page).to have_content("0 projects")
    end

    describe "budget list item" do
      let!(:component) do
        create(:budgets_component,
               :with_vote_threshold_percent,
               manifest:,
               participatory_space: participatory_process,
               settings: { landing_page_content: description })
      end
      let(:description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
      let(:budget) { budgets.first }
      let(:item) { page.find("#budgets .card--list__item", match: :first) }
      let!(:projects) { create_list(:project, 3, budget:, budget_amount: 10_000_000) }

      before do
        login_as user, scope: :user
      end

      it_behaves_like "has embedded video in description", :description

      it "has a clickable title" do
        expect(item).to have_link(translated(budget.title), href: budget_path(budget))
      end

      context "when an item is bookmarked" do
        let!(:order) { create(:order, user:, budget:) }
        let!(:line_item) { create(:line_item, order:, project: projects.first) }

        it "shows a finish voting link" do
          visit_component

          expect(item).to have_link("Finish voting", href: budget_path(budget))
        end

        it "shows the projects count and it has no remove vote link" do
          visit_component

          expect(page).to have_no_content("Remove vote")
          expect(item).to have_content("3 projects")
        end
      end

      context "when an item is voted" do
        let(:item) { page.find("#voted-budgets .card--list__item:first-child") }

        let!(:order) do
          order = create(:order, user:, budget:)
          order.projects = [projects.first]
          order.checked_out_at = Time.current
          order.save!
          order
        end

        it "shows the check icon" do
          visit_component

          expect(item).to have_css("div.card__highlight-text svg.fill-success")
          expect(item).to have_link("See projects", href: budget_path(budget))
        end

        it "shows the projects count" do
          expect(page).to have_content("0 projects")
        end

        it "has a link to remove vote" do
          visit_component

          expect(item).to have_content("Delete your vote")
          within item do
            accept_confirm { click_on "Delete your vote" }
            expect(Decidim::Budgets::Order.where(budget:)).to be_blank
          end
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
