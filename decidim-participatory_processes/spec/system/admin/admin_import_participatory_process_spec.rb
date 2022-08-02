# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "json"

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
      end
      
      hero_file = Decidim::Dev.asset("city.jpeg")
      banner_file = Decidim::Dev.asset("city2.jpeg")
      dest_folder = "../spec/decidim_dummy_app/uploads/decidim/participatory_process/hero_image/1/"
      FileUtils.mkdir_p(dest_folder)
      
      FileUtils.cp(hero_file, dest_folder)
      FileUtils.cp(banner_file, dest_folder)
      
      file_json = File.read(Decidim::Dev.asset("participatory_processes.json"))
      original_json = JSON.parse(file_json).first
      
      hero_url = "#{current_host}:#{Capybara.current_session.server.port}/uploads/decidim/participatory_process/hero_image/1/city.jpeg"
      banner_url = "#{current_host}:#{Capybara.current_session.server.port}/uploads/decidim/participatory_process/hero_image/1/city.jpeg"
      
      original_json['remote_hero_image_url'] = hero_url
      original_json['remote_banner_image_url'] = banner_url
      
      file = Tempfile.new('participatory_processes')
      file.write(original_json)
      file.rewind
      
      participatory_processes_json = file.read
      dynamically_attach_file(:participatory_process_document, participatory_processes_json)

      click_button "Import"
    end

    it "imports the json document" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Not published")

      click_link "Import participatory process"

      click_link "Phases"
      within ".table-list" do
        expect(page).to have_content(translated("Magni."))
      end

      click_link "Categories"
      within ".table-list" do
        expect(page).to have_content(translated("Illum nesciunt praesentium explicabo qui."))
        expect(page).to have_content(translated("Expedita sint earum rerum consequatur."))
      end

      click_link "Components"
      expect(Decidim::ParticipatoryProcess.last.components.size).to eq(3)
      within ".table-list" do
        Decidim::ParticipatoryProcess.last.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end

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
