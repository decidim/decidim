# frozen_string_literal: true

require "spec_helper"

describe "Admin manages project permissions" do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component: current_component) }
  let!(:project) { create(:project, budget:) }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    within "tr", text: translated(budget.title) do
      find("button[data-component='dropdown']").click
      click_on "Manage projects"
    end
    within "tr", text: translated(project.title) do
      find("button[data-component='dropdown']").click
      click_on "Permissions"
    end
  end

  it "Saves the permissions" do
    expect(page).to have_content("Edit permissions")

    within "fieldset", text: "Vote" do
      page.check("Example authorization (Direct)")
    end
    click_on "Submit"
    expect(page).to have_content("Permissions updated successfully")
    within "tr", text: translated(budget.title) do
      find("button[data-component='dropdown']").click
      click_on "Manage projects"
    end
    within "tr", text: translated(project.title) do
      find("button[data-component='dropdown']").click
      click_on "Permissions"
    end
    within "fieldset", text: "Vote" do
      expect(page).to have_checked_field("Example authorization (Direct)")
    end
  end
end
