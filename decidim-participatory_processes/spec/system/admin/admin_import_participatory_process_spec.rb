# frozen_string_literal: true

require "spec_helper"

describe "Admin imports participatory process", type: :system do
  include_context "when admin administrating a participatory process"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "with context" do
    before "Imports the process with the basic fields" do
      click_link "Import", match: :first

      within ".import_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Import participatory process",
          es: "Importación del proceso participativo",
          ca: "Importació del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-import"
        attach_file :participatory_process_document, Decidim::Dev.asset("participatory_processes.json")
      end
    end

    it "imports the process with steps" do
      page.check("participatory_process[import_steps]")
      click_button "Import"

      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Not published")

      click_link "Import participatory process"
      click_link "Phases"

      within ".table-list" do
        Decidim::ParticipatoryProcess.last.steps.each do |step|
          expect(page).to have_content(translated(step.title))
        end
      end
    end

    it "imports the process with categories" do
      page.check("participatory_process[import_categories]")
      click_button "Import"

      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Not published")

      click_link "Import participatory process"
      click_link "Categories"

      within ".table-list" do
        Decidim::ParticipatoryProcess.last.categories.each do |category|
          expect(page).to have_content(translated(category.name))
        end
      end
    end

    it "imports the process with components" do
      page.check("participatory_process[import_components]")
      click_button "Import"

      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Not published")

      click_link "Import participatory process"
      click_link "Components"

      within ".table-list" do
        Decidim::ParticipatoryProcess.last.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end
    end

    it "imports the process with attachments" do
      page.check("participatory_process[import_attachments]")
      click_button "Import"

      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Not published")

      click_link "Import participatory process"
      click_link "Files"

      if Decidim::ParticipatoryProcess.last.attachments.any?
        within ".table-list" do
          Decidim::ParticipatoryProcess.last.attachments.each do |attachment|
            expect(page).to have_content(translated(attachment.title))
          end
        end
      end
    end
  end
end
