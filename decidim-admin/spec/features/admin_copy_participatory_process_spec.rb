# frozen_string_literal: true
require "spec_helper"

describe "Admin copy participatory process", type: :feature do
  include_context "participatory process admin"
  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:category) do
    create(
      :category,
      participatory_process: participatory_process
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  context "without any context" do
    it "copies the process with the basic fields" do
      page.find(".action-icon--copy", match: :first).click

      within ".copy_participatory_process" do
        fill_in_i18n(
          :participatory_process_copy_title,
          "#title-tabs",
          en: "Copy participatory process",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :participatory_process_copy_slug, with: "pp-copy"
        click_button "Copy"
      end

      expect(page).to have_content("Successfully")
      expect(page).to have_content("Copy participatory process")
      expect(page).to have_content("Not published")
    end
  end

  context "with context" do
    before do
      page.find(".action-icon--copy", match: :first).click

      within ".copy_participatory_process" do
        fill_in_i18n(
          :participatory_process_copy_title,
          "#title-tabs",
          en: "Copy participatory process",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :participatory_process_copy_slug, with: "pp-copy-with-steps"
      end
    end

    it "copies the process with steps" do
      page.check("participatory_process_copy[copy_steps]")
      click_button "Copy"

      expect(page).to have_content("Successfully")

      click_link "Copy participatory process"
      click_link "Steps"

      within ".table-list" do
        participatory_process.steps.each do |step|
          expect(page).to have_content(translated(step.title))
        end
      end
    end

    it "copies the process with steps" do
      page.check("participatory_process_copy[copy_categories]")
      click_button "Copy"

      expect(page).to have_content("Successfully")

      click_link "Copy participatory process"
      click_link "Categories"

      within ".table-list" do
        participatory_process.categories.each do |category|
          expect(page).to have_content(translated(category.name))
        end
      end
    end
  end
end
