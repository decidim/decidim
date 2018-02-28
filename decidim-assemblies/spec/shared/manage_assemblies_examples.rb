# frozen_string_literal: true

shared_examples "manage assemblies" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  describe "updating an assembly" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }

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

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  describe "updating an assembly without images" do
    before do
      visit decidim_admin_assemblies.assemblies_path
    end

    it "update an assembly without images does not delete them" do
      click_link translated(assembly.title)
      click_submenu_link "Info"
      click_button "Update"

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_css("img[src*='#{assembly.hero_image.url}']")
      expect(page).to have_css("img[src*='#{assembly.banner_image.url}']")
    end
  end

  describe "previewing assemblies" do
    context "when the assembly is unpublished" do
      let!(:assembly) { create(:assembly, :unpublished, organization: organization) }

      it "allows the user to preview the unpublished assembly" do
        within find("tr", text: translated(assembly.title)) do
          click_link "Preview"
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(assembly.title))
      end
    end

    context "when the assembly is published" do
      let!(:assembly) { create(:assembly, organization: organization) }

      it "allows the user to preview the unpublished assembly" do
        within find("tr", text: translated(assembly.title)) do
          click_link "Preview"
        end

        expect(page).to have_current_path decidim_assemblies.assembly_path(assembly)
        expect(page).to have_content(translated(assembly.title))
      end
    end
  end

  describe "viewing a missing assembly" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_assemblies.assembly_path(99_999_999) }
    end
  end

  describe "publishing an assembly" do
    let!(:assembly) { create(:assembly, :unpublished, organization: organization) }

    before do
      click_link translated(assembly.title)
    end

    it "publishes the assembly" do
      click_link "Publish"
      expect(page).to have_content("published successfully")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).to be_published
    end
  end

  describe "unpublishing an assembly" do
    let!(:assembly) { create(:assembly, organization: organization) }

    before do
      click_link translated(assembly.title)
    end

    it "unpublishes the assembly" do
      click_link "Unpublish"
      expect(page).to have_content("unpublished successfully")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_assemblies.edit_assembly_path(assembly)

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

      expect(page).to have_selector("#assembly_scope_id.disabled")
      expect(page).to have_selector("#assembly_scope_id .picker-values div input[disabled]", visible: false)

      within ".edit_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end
end
