# frozen_string_literal: true

require "spec_helper"

describe "Admin applies questionnaire templates", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:participatory_space) { create(:participatory_process, organization: organization) }
  let!(:component) { create(:component, participatory_space: participatory_space) }
  let!(:questionnaire_template) { create(:questionnaire_template, :with_all_questions, organization: organization, skip_injection: true) }

  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
    ActionController::Base.allow_forgery_protection = false
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.components_path(participatory_space)
  end

  it "installs a survey component" do
    find("button[data-toggle=add-component-dropdown]").click

    within "#add-component-dropdown" do
      find(".surveys").click
    end

    click_on "Add component"
    click_on "Survey"

    page.all("svg.icon--pencil")[1].click

    select(translated_attribute(questionnaire_template.name), from: "select-template")
    expect(page).to have_content("If you are human, ignore this field")
    click_on "Create from template"

    expect(page).to have_content("Template applied successfully")
  end
end
