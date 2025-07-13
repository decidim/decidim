# frozen_string_literal: true

shared_examples "copy assemblies" do
  let!(:assembly) { create(:assembly, organization:) }
  let!(:component) { create(:component, manifest_name: :dummy, participatory_space: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "without any context" do
    it "copies the assembly with the basic fields" do
      within("tr", text: translated_attribute(assembly.title)) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      within ".copy_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Copy assembly",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :assembly_slug, with: "pp-copy"
        click_on "Copy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Copy assembly")
      expect(page).to have_content("Unpublished")
    end
  end

  context "with context" do
    before do
      within("tr", text: translated_attribute(assembly.title)) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

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

    it "copies the assembly with components" do
      page.check("assembly[copy_components]")
      click_on "Copy"

      expect(page).to have_content("successfully")

      within "tr", text: "Copy assembly" do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
      within_admin_sidebar_menu do
        click_on "Components"
      end

      within ".table-list" do
        assembly.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end
    end
  end

  context "when copying a child assembly" do
    let!(:assembly_parent) { create(:assembly, organization:) }
    let!(:assembly) { create(:assembly, parent: assembly_parent, organization:) }

    it "copies the child assembly with the basic fields" do
      click_on "Assemblies", match: :first

      within("tr", text: translated_attribute(assembly_parent.title)) do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      within ".copy_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "Copy assembly",
          es: "Copia del proceso participativo",
          ca: "Còpia del procés participatiu"
        )
        fill_in :assembly_slug, with: "pp-copy"
        click_on "Copy"
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Copy assembly")
      expect(page).to have_content("Unpublished")
    end
  end
end
