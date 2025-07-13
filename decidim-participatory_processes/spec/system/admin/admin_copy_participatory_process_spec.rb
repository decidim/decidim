# frozen_string_literal: true

require "spec_helper"

describe "Admin copies participatory process" do
  include_context "when admin administrating a participatory process"

  let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "without any context" do
    it "copies the process with the basic fields" do
      within("tr", text: translated(participatory_process.title)) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      within ".copy_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Copy participatory process",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-copy"
        click_on "Copy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Copy participatory process")
      expect(page).to have_content("Unpublished")
    end
  end

  context "with context" do
    before do
      within("tr", text: translated(participatory_process.title)) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      within ".copy_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Copy participatory process",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-copy-with-steps"
      end
    end

    it "copies the process with steps" do
      page.check("participatory_process[copy_steps]")
      click_on "Copy"

      expect(page).to have_content("successfully")

      within "tr", text: "Copy participatory process" do
        click_on "Copy participatory process"
      end

      within_admin_sidebar_menu do
        click_on "Phases"
      end

      within ".table-list" do
        participatory_process.steps.each do |step|
          expect(page).to have_content(translated(step.title))
        end
      end
    end

    it "copies the process with components" do
      page.check("participatory_process[copy_components]")
      click_on "Copy"

      expect(page).to have_content("successfully")

      within "tr", text: "Copy participatory process" do
        click_on "Copy participatory process"
      end

      within_admin_sidebar_menu do
        click_on "Components"
      end

      within ".table-list" do
        participatory_process.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end
    end
  end
end
