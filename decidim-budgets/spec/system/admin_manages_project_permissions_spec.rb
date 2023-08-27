# frozen_string_literal: true

require "spec_helper"

describe "Admin manages project permissions", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component: current_component) }
  let!(:project) { create(:project, budget:) }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
    within find("tr", text: translated(project.title)) do
      page.find(".action-icon--permissions").click
    end
  end

  it "Saves the permissions" do
    expect(page).to have_content("Edit permissions")

    within find("fieldset", text: "Vote") do
      page.check("Example authorization (Direct)")
    end
    click_button "Submit"
    expect(page).to have_content("Permissions updated successfully")
    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
    within find("tr", text: translated(project.title)) do
      expect(page).to have_css(".action-icon--highlighted")
      page.find(".action-icon--permissions").click
    end
    within find("fieldset", text: "Vote") do
      expect(page).to have_checked_field("Example authorization (Direct)")
    end
  end
end
