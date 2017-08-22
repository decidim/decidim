# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", type: :feature do
  include_context "assembly administration"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  context "creating an assembly" do
    before do
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

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within ".container" do
        expect(current_path).to eq decidim_admin_assemblies.assemblies_path
        expect(page).to have_content("My assembly")
      end
    end
  end

  context "updating an assembly" do
    before do
      click_link translated(assembly.title)
    end

    it "updates an assembly" do
      fill_in_i18n(
        :assembly_title,
        "#assembly-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      attach_file :assembly_banner_image, image3_path

      within ".edit_assembly" do
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).not_to have_css("img[src*='#{image2_filename}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  context "updating an assembly without images" do
    let!(:assembly3) { create(:assembly, organization: organization) }

    before do
      visit decidim_admin_assemblies.assemblies_path
    end

    it "update an assembly without images does not delete them" do
      click_link translated(assembly3.title)
      click_submenu_link "Info"
      click_button "Update"

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_css("img[src*='#{assembly3.hero_image.url}']")
      expect(page).to have_css("img[src*='#{assembly3.banner_image.url}']")
    end
  end

  context "deleting an assembly" do
    let!(:assembly2) { create(:assembly, organization: organization) }

    before do
      visit decidim_admin_assemblies.assemblies_path
    end

    it "deletes an assembly" do
      click_link translated(assembly2.title)
      click_link "Destroy"

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(assembly2.title))
      end
    end
  end

  context "previewing assemblies" do
    context "when the assembly is unpublished" do
      let!(:assembly) { create(:assembly, :unpublished, organization: organization) }

      it "allows the user to preview the unpublished assembly" do
        within find("tr", text: translated(assembly.title)) do
          page.find("a.action-icon--preview").click
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(assembly.title))
      end
    end

    context "when the assembly is published" do
      let!(:assembly) { create(:assembly, organization: organization) }

      it "allows the user to preview the unpublished assembly" do
        within find("tr", text: translated(assembly.title)) do
          page.find("a.action-icon--preview").click
        end

        expect(current_path).to eq decidim_assemblies.assembly_path(assembly)
        expect(page).to have_content(translated(assembly.title))
      end
    end
  end

  context "viewing a missing assembly" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_assemblies.assembly_path(99_999_999) }
    end
  end

  context "publishing an assembly" do
    let!(:assembly) { create(:assembly, :unpublished, organization: organization) }

    before do
      click_link translated(assembly.title)
    end

    it "publishes the assembly" do
      click_link "Publish"
      expect(page).to have_content("published successfully")
      expect(page).to have_content("Unpublish")
      expect(current_path).to eq decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).to be_published
    end
  end

  context "unpublishing an assembly" do
    let!(:assembly) { create(:assembly, organization: organization) }

    before do
      click_link translated(assembly.title)
    end

    it "unpublishes the assembly" do
      click_link "Unpublish"
      expect(page).to have_content("unpublished successfully")
      expect(page).to have_content("Publish")
      expect(current_path).to eq decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_assembly) { create(:assembly) }

    before do
      visit decidim_admin_assemblies.assemblies_path
    end

    it "doesn't let the admin manage assemblies form other organizations" do
      within "table" do
        expect(page).not_to have_content(external_assembly.title["en"])
      end
    end
  end

  context "when the assembly has a scope" do
    let(:scope) { create(:scope, organization: organization) }

    before do
      assembly.update_attributes!(scopes_enabled: true, scope: scope)
    end

    it "disables the scope for the assembly" do
      click_link translated(assembly.title)

      uncheck :assembly_scopes_enabled

      expect(page).to have_selector("select#assembly_scope_id[disabled]")

      within ".edit_assembly" do
        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end
    end
  end
end
