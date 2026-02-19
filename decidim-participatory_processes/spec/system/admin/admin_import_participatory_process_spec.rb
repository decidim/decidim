# frozen_string_literal: true

require "spec_helper"

describe "Admin imports participatory process" do
  include_context "when admin administrating a participatory process"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "when viewing the import page" do
    before do
      within_admin_menu do
        click_on "Import"
      end
    end

    it "displays the import help text" do
      expect(page).to have_content("This import feature allows you to create a new participatory process from an exported JSON file")
    end
  end

  context "with context" do
    before "Imports the process with the basic fields" do
      within_admin_menu do
        click_on "Import"
      end

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

      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/participatory_process/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/participatory_process_group/hero_image/1/city.jpeg",
        "image/jpeg"
      )

      dynamically_attach_file(:participatory_process_document, Decidim::Dev.asset("participatory_processes.json"))

      click_on "Import"
    end

    it "imports the json document" do
      expect(page).to have_callout("Participatory process successfully imported.")
      expect(page).to have_content("Import participatory process")
      within "table" do
        expect(page).to have_content("Unpublished")
      end

      within "tr", text: "Import participatory process" do
        click_on "Import participatory process"
      end

      within_admin_sidebar_menu do
        click_on "Phases"
      end

      within ".table-list" do
        expect(page).to have_content(translated("Magni."))
      end

      within_admin_sidebar_menu do
        click_on "Components"
      end

      expect(Decidim::ParticipatoryProcess.last.components.size).to eq(3)
      within ".table-list" do
        Decidim::ParticipatoryProcess.last.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end

      within_admin_sidebar_menu do
        click_on "Attachments"
      end

      if Decidim::ParticipatoryProcess.last.attachments.any?
        within ".table-list" do
          Decidim::ParticipatoryProcess.last.attachments.each do |attachment|
            expect(page).to have_content(translated(attachment.title))
          end
        end
      end
    end
  end

  context "when hero image URL returns 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("participatory_processes.json"))) }
    let(:json_file) do
      Tempfile.new(["participatory_processes", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["remote_hero_image_url"] = "http://example.com/missing-hero.jpg"

      stub_request(:get, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/participatory_process_group/hero_image/1/city.jpeg",
        "image/jpeg"
      )

      within_admin_menu do
        click_on "Import"
      end

      within ".import_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Import process with 404 hero",
          es: "Importación del proceso participativo",
          ca: "Importació del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-import-404"
      end

      dynamically_attach_file(:participatory_process_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about the missing hero image" do
      expect(page).to have_callout("Participatory process successfully imported")
      expect(page).to have_content("Import process with 404 hero")

      within ".flash.warning" do
        expect(page).to have_content(/The hero image could not be imported \(404 Not Found\)\./i)
      end
    end
  end

  context "when process group hero image URL returns 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("participatory_processes.json"))) }
    let(:json_file) do
      Tempfile.new(["participatory_processes", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["participatory_process_group"]["remote_hero_image_url"] = "http://example.com/missing-group-hero.jpg"

      stub_request(:get, "http://localhost:3000/uploads/decidim/participatory_process/hero_image/1/city.jpeg")
        .to_return(status: 200, body: File.read(Decidim::Dev.asset("city.jpeg")))
      stub_request(:head, "http://localhost:3000/uploads/decidim/participatory_process/hero_image/1/city.jpeg")
        .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })
      stub_request(:get, "http://example.com/missing-group-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-group-hero.jpg")
        .to_return(status: 404, body: "Not Found")

      within_admin_menu do
        click_on "Import"
      end

      within ".import_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Import process with 404 group hero",
          es: "Importación del proceso participativo",
          ca: "Importació del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-import-404-group"
      end

      dynamically_attach_file(:participatory_process_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about the missing group hero image" do
      expect(page).to have_callout("Participatory process successfully imported")
      expect(page).to have_content("Import process with 404 group hero")

      within ".flash.warning" do
        expect(page).to have_content(/The hero image could not be imported \(404 Not Found\)\./i)
      end
    end
  end

  context "when attachment URLs return 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("participatory_processes.json"))) }
    let(:json_file) do
      Tempfile.new(["participatory_processes", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["attachments"]["files"].each do |file|
        file["remote_file_url"] = "http://example.com/missing-attachment.pdf"
      end

      stub_request(:head, "http://example.com/missing-attachment.pdf")
        .to_return(status: 404, body: "Not Found")

      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/participatory_process/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/participatory_process_group/hero_image/1/city.jpeg",
        "image/jpeg"
      )

      within_admin_menu do
        click_on "Import"
      end

      within ".import_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Import process with 404 attachments",
          es: "Importación del proceso participativo",
          ca: "Importació del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-import-404-attachments"
        check :participatory_process_import_attachments
      end

      dynamically_attach_file(:participatory_process_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about missing attachments" do
      expect(page).to have_content("Participatory process successfully imported.")
      expect(page).to have_content("Import process with 404 attachments")

      within ".flash.warning" do
        expect(page).to have_content(/The attachment ".+" could not be imported \(404 Not Found\)\./i)
      end
    end
  end
end
