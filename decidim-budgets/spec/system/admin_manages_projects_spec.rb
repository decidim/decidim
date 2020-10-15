# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages projects", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: current_component }
  let!(:project) { create :project, budget: budget }

  include_context "when managing a component as an admin"

  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
  end

  it_behaves_like "manage projects"
  it_behaves_like "import proposals to projects"
end
