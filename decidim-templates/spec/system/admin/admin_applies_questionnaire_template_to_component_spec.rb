# frozen_string_literal: true

require "spec_helper"

describe "Admin applies questionnaire templates" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:participatory_space) { create(:participatory_process, organization:) }
  let!(:component) { create(:component, participatory_space:) }
  let!(:questionnaire_template) { create(:questionnaire_template, :with_all_questions, organization:, skip_injection: true) }

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
    find("button[data-target=add-component-dropdown]").click

    within "#add-component-dropdown" do
      click_on "Surveys"
    end

    click_on "Add component"
    within ".table-scroll" do
      click_on "Surveys"
    end
    click_on "New survey"

    fill_in_i18n :survey_title, "#survey-title-tabs", en: "Hello"
    fill_in_i18n_editor :survey_tos, "#survey-tos-tabs", en: "Hello"

    click_on "Save"
    click_on "Questions"

    choose("Select template")
    select(translated_attribute(questionnaire_template.name), from: "select-template")
    expect(page).to have_content("If you are human, ignore this field")
    click_on "Continue"

    expect(page).to have_content("Template applied successfully.")
  end
end
