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
      expect(page).to have_content("This import feature allows you to create a new assembly from an exported JSON file")
    end
  end

  context "when importing the assembly with basic fields" do
    before do
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg",
        "image/jpeg"
      )
      stub_get_request_with_format(
        "http://localhost:3000/uploads/decidim/assembly/banner_image/1/city2.jpeg",
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
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly")
      expect(page).to have_content("Unpublished")

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
          expect(page).to have_content(translated(component.name))
        end
      end

      within_admin_sidebar_menu do
        click_on "Attachments"
      end
      if Decidim::Assembly.last.attachments.any?
        within ".table-list" do
          Decidim::Assembly.last.attachments.each do |attachment|
            expect(page).to have_content(translated(attachment.title))
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
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["remote_hero_image_url"] = "http://example.com/missing-hero.jpg"

      stub_request(:get, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:get, "http://localhost:3000/uploads/decidim/assembly/banner_image/1/city2.jpeg")
        .to_return(status: 200, body: File.read(Decidim::Dev.asset("city2.jpeg")))
      stub_request(:head, "http://localhost:3000/uploads/decidim/assembly/banner_image/1/city2.jpeg")
        .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })

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
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly with 404 hero")

      within ".flash.warning" do
        expect(page).to have_content(/The hero image could not be imported due to an error/i)
      end
    end
  end

  context "when banner image URL returns 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["remote_banner_image_url"] = "http://example.com/missing-banner.jpg"

      stub_request(:get, "http://example.com/missing-banner.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-banner.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:get, "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg")
        .to_return(status: 200, body: File.read(Decidim::Dev.asset("city.jpeg")))
      stub_request(:head, "http://localhost:3000/uploads/decidim/assembly/hero_image/1/city.jpeg")
        .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly with 404 banner",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import-404-banner"
      end

      dynamically_attach_file(:assembly_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows a warning about the missing banner image" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly with 404 banner")

      within ".flash.warning" do
        expect(page).to have_content(/The banner image could not be imported due to an error/i)
      end
    end
  end

  context "when both hero and banner image URLs return 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end

    before do
      json_data.first["remote_hero_image_url"] = "http://example.com/missing-hero.jpg"
      json_data.first["remote_banner_image_url"] = "http://example.com/missing-banner.jpg"

      stub_request(:get, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-hero.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:get, "http://example.com/missing-banner.jpg")
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, "http://example.com/missing-banner.jpg")
        .to_return(status: 404, body: "Not Found")

      within_admin_menu do
        click_on "Import"
      end

      within ".import_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Import assembly with 404 images",
          es: "Importación de la asamblea",
          ca: "Importació de l'asamblea"
        )
        fill_in :assembly_slug, with: "as-import-404-both"
      end

      dynamically_attach_file(:assembly_document, uploaded_file.path)
      click_on "Import"
    end

    it "imports successfully and shows warnings for both missing images" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly with 404 images")

      within ".flash.warning" do
        expect(page).to have_content(/The hero image could not be imported due to an error/i)
        expect(page).to have_content(/The banner image could not be imported due to an error/i)
      end
    end
  end

  context "when both image URLs are too long and return 404" do
    let(:json_data) { JSON.parse(File.read(Decidim::Dev.asset("assemblies.json"))) }
    let(:json_file) do
      Tempfile.new(["assemblies", ".json"]).tap do |file|
        file.write(json_data.to_json)
        file.rewind
      end
    end
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(json_file.path, "application/json")
    end
    let(:hero_image_url) { "http://example.com/#{"a" * 5000}.jpg" }
    let(:banner_image_url) { "http://example.com/#{"b" * 5000}.jpg" }

    before do
      json_data.first["remote_hero_image_url"] = hero_image_url
      json_data.first["remote_banner_image_url"] = banner_image_url

      stub_request(:get, hero_image_url)
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, hero_image_url)
        .to_return(status: 404, body: "Not Found")
      stub_request(:get, banner_image_url)
        .to_return(status: 404, body: "Not Found")
      stub_request(:head, banner_image_url)
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

    it "imports successfully and shows warnings for both missing images" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import assembly with long 404 images")

      within ".flash.warning" do
        expect(page).to have_content(/The hero image could not be imported due to an error/i)
        expect(page).to have_content(/The banner image could not be imported due to an error/i)
      end
    end
  end
end
