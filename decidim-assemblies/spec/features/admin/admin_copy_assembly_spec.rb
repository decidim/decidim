# frozen_string_literal: true

require "spec_helper"

describe "Admin copies assembly", type: :feature do
  include_context "assembly administration"

  let!(:assembly) { create(:assembly, organization: organization) }
  let!(:feature) { create :feature, manifest_name: :dummy, participatory_space: assembly }
  let!(:category) do
    create(
      :category,
      participatory_space: assembly
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "without any context" do
    it "copies the assembly with the basic fields" do
      page.find(".action-icon--copy", match: :first).click

      within ".copy_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Copy assembly",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :assembly_slug, with: "pp-copy"
        click_button "Copy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Copy assembly")
      expect(page).to have_content("Not published")
    end
  end

  context "with context" do
    before do
      page.find(".action-icon--copy", match: :first).click

      within ".copy_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Copy assembly",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :assembly_slug, with: "assembly-copy"
      end
    end

    it "copies the assembly with categories" do
      page.check("assembly[copy_categories]")
      click_button "Copy"

      expect(page).to have_content("successfully")

      click_link "Copy assembly"
      click_link "Categories"

      within ".table-list" do
        assembly.categories.each do |category|
          expect(page).to have_content(translated(category.name))
        end
      end
    end

    it "copies the assembly with features" do
      page.check("assembly[copy_features]")
      click_button "Copy"

      expect(page).to have_content("successfully")

      click_link "Copy assembly"
      click_link "Features"

      within ".table-list" do
        assembly.features.each do |feature|
          expect(page).to have_content(translated(feature.name))
        end
      end
    end
  end
end
