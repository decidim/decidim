# frozen_string_literal: true

require "spec_helper"

describe "Admin imports assembly" do
  include_context "when admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "when viewing the import page" do
    before do
      within_admin_menu do
        click_on "Import"
      end
    end

    it "displays the import help text" do
      expect(page).to have_text("This import feature allows you to create a new assembly from an exported JSON file")
    end
  end

  context "when importing the assembly with basic fields" do
    before do
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/31/Exampledocument.pdf",
        "application/pdf"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/attachment/file/32/city.jpeg",
        "image/jpeg"
      )

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import"
      end

      dynamically_attach_file(:assembly_document, Decidim::Dev.asset("assemblies.json"))
      click_on "Import"
    end

    it "imports the json document" do
      expect(page).to have_callout("Assembly successfully imported.")
      expect(page).to have_text("Import assembly")
      within "table" do
        expect(page).to have_text("Unpublished")
      end

      within "tr", text: "Import assembly" do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end

      within_admin_sidebar_menu do
        click_on "Components"
      end
      expect(Decidim::Assembly.last.components.size).to eq(8)
      within ".table-list" do
        Decidim::Assembly.last.components.each do |component|
          expect(page).to have_text(translated(component.name))
        end
      end

      within_admin_sidebar_menu do
        click_on "Attachments"
      end
      if Decidim::Assembly.last.attachments.any?
        within ".table-list" do
          Decidim::Assembly.last.attachments.each do |attachment|
            expect(page).to have_text(translated(attachment.title))
          end
        end
      end
    end
  end

  context "when hero image URL returns 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Decidim::Dev.uploaded_file(json_file.path, "application/json")
    end

    before do
      json_data.first["remote_hero_image_url"] = "http://example.com/missing-hero.jpg"

      stub_request(:get, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly with 404 hero",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import-404"
      end

      dynamically_attach_file(:assembly_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about the missing hero image" do
      expect(page).to have_callout("Assembly successfully imported.")
      expect(page).to have_callout("Import assembly with 404 hero")

      within ".flash.warning" do
        expect(page).to have_text(/The hero image could not be imported \(404 Not Found\)\./i)
      end
    end
  end

  context "when hero image URL is too long and returns 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Decidim::Dev.uploaded_file(json_file.path, "application/json")
    end
    let(:hero_image_url) { "http://example.com/#{"a" * 5000}.jpg" }

    before do
      json_data.first["remote_hero_image_url"] = hero_image_url

      stub_request(:get, hero_image_url)
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, hero_image_url)
        .to_return(status: 404, body: "Not Found")

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly with long 404 images",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import-404-long"
      end

      dynamically_attach_file(:assembly_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows warnings for missing hero image" do
      expect(page).to have_callout("Assembly successfully imported.")
      expect(page).to have_callout("Import assembly with long 404 images")

      within ".flash.warning" do
        expect(page).to have_text(/The hero image could not be imported \(404 Not Found\)\./i)
      end
    end
  end

  context "when attachment URLs return 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Decidim::Dev.uploaded_file(json_file.path, "application/json")
    end

    before do
      json_data.first["attachments"]["files"].each do |file|
        file["remote_file_url"] = "http://example.com/missing-attachment.pdf"
      end

      stub_request(:head, "http://example.com/missing-attachment.pdf")
        .to_return(status: 404, body: "Not Found")

      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg",
        "image/jpeg"
      )

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly with 404 attachments",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import-404-attachments"
        check :assembly_import_attachments
      end

      dynamically_attach_file(:assembly_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about missing attachments" do
      expect(page).to have_callout("Assembly successfully imported.")
      expect(page).to have_text("Import assembly with 404 attachments")

      within ".flash.warning" do
        expect(page).to have_text(/The attachment ".+" could not be imported \(404 Not Found\)\./i)
      end
    end
  end
end
