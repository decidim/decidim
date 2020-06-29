# frozen_string_literal: true

require "spec_helper"

describe "Explore Budgets", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  context "with only one budget" do
    let!(:budgets) { create_list(:budget, 1, component: component) }

    it "redirects to the only budget details" do
      visit_component

      expect(page).to have_content("More information")
    end
  end

  context "with many budgets" do
    let!(:budgets) { create_list(:budget, 6, component: component) }

    it "lists all the budgets" do
      visit_component

      expect(page).to have_selector(".card--list__item", count: 6)

      budgets.each do |budget|
        expect(page).to have_content(translated(budget.title))
      end
    end
  end
end
