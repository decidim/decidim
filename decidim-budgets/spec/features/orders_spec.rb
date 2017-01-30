# frozen_string_literal: true
require "spec_helper"

describe "Orders", type: :feature do
  include_context "feature"
  let(:manifest_name) { "budgets" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:projects) { create_list(:project, 3, feature: feature, budget: 25_000_000) }
  let(:project) { projects.first }

  let!(:feature) do
    create(:budget_feature,
           :with_total_budget,
           manifest: manifest,
           participatory_process: participatory_process)
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
      visit_feature
    end

    context "when the user has not a pending order" do
      it "adds a project to the current order" do
        within "#project-#{project.id}-data" do
          page.find('.budget--list__action').click
        end

        expect(page).to have_content "ASSIGNED: 25.000.000 €"
        expect(page).to have_content "1 project selected"

        within ".budget-summary__selected" do
          expect(page).to have_content project.title
        end

        expect(page).to have_selector ".budget-progress[aria-valuenow=25]"
        expect(page).to have_selector '.budget-list__data--added', count: 1
      end
    end
  end
end
