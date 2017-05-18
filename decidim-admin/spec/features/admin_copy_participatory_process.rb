# frozen_string_literal: true
require "spec_helper"

describe "Admin copy participatory process", type: :feature do
  include_context "participatory process admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  it "without any context" do
    page.find('.action-icon--copy', match: :first).click

    within ".copy_participatory_process" do
      fill_in_i18n(
        :participatory_process_copy_title,
        "#title-tabs",
        en: "Copy participatory process",
        es: "Copia del proceso participativo",
        ca: "Còpia del procés participatiu"
      )
      fill_in :participatory_process_copy_slug, with: 'pp-copy'
      click_button "Copy"
    end

    expect(page).to have_content("Successfully")
    expect(page).to have_content("Copy participatory process")
    expect(page).to have_content("Not published")
  end
end