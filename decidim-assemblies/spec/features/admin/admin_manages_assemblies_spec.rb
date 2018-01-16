# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", type: :feature do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assemblies"

  describe "creating an assembly" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path

      within ".secondary-nav__actions" do
        page.find("a.button").click
      end
    end

    it "creates a new assembly" do
      within ".new_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "My assembly",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :assembly_subtitle,
          "#assembly-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :assembly_short_description,
          "#assembly-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :assembly_description,
          "#assembly-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        attach_file :assembly_hero_image, image1_path
        attach_file :assembly_banner_image, image2_path

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_assemblies.assemblies_path
        expect(page).to have_content("My assembly")
      end
    end
  end

  describe "deleting an assembly" do
    let!(:assembly2) { create(:assembly, organization: organization) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it "deletes an assembly" do
      click_link translated(assembly2.title)
      accept_confirm { click_link "Destroy" }

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(assembly2.title))
      end
    end
  end
end
