# frozen_string_literal: true

shared_examples "manage assemblies" do
  describe "updating an assembly" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }

    let(:assembly_parent_id_options) { page.find("#assembly_parent_id").find_all("option").map(&:value) }

    before do
      click_link "Configure"
    end

    it "updates an assembly" do
      fill_in_i18n(
        :assembly_title,
        "#assembly-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      dynamically_attach_file(:assembly_banner_image, image3_path, remove_before: true)

      within ".edit_assembly" do
        expect(assembly_parent_id_options).not_to include(assembly.id)
        fill_in "assembly[creation_date]", with: Date.yesterday
        fill_in "assembly[included_at]", with: Date.current
        fill_in "assembly[duration]", with: Date.tomorrow
        fill_in "assembly[closing_date]", with: Date.tomorrow
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
        expect(page).to have_css("input[value='#{Date.yesterday}']")
        expect(page).to have_css("input[value='#{Date.current}']")
        expect(page).to have_css("input[value='#{Date.tomorrow}']", count: 2)
      end
    end
  end

  describe "updating an assembly without images" do
    before do
      within find("tr", text: translated(assembly.title)) do
        click_link "Configure"
      end
    end

    it "update an assembly without images does not delete them" do
      click_submenu_link "Info"
      click_button "Update"

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_css("img[src*='#{assembly.attached_uploader(:hero_image).path}']")
      expect(page).to have_css("img[src*='#{assembly.attached_uploader(:banner_image).path}']")
    end
  end

  describe "previewing assemblies" do
    context "when the assembly is unpublished" do
      let!(:assembly) { create(:assembly, :unpublished, organization:, parent: parent_assembly) }

      it "allows the user to preview the unpublished assembly" do
        within find("tr", text: translated(assembly.title)) do
          click_link "Preview"
        end

        expect(page).to have_css(".process-header")
        expect(page).to have_content(translated(assembly.title))
      end
    end

    context "when the assembly is published" do
      let!(:assembly) { create(:assembly, organization:, parent: parent_assembly) }

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
    let!(:assembly) { create(:assembly, :unpublished, organization:, parent: parent_assembly) }

    before do
      within find("tr", text: translated(assembly.title)) do
        click_link "Configure"
      end
    end

    it "publishes the assembly" do
      click_link "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).to be_published
    end
  end

  describe "unpublishing an assembly" do
    let!(:assembly) { create(:assembly, organization:, parent: parent_assembly) }

    before do
      within find("tr", text: translated(assembly.title)) do
        click_link "Configure"
      end
    end

    it "unpublishes the assembly" do
      click_link "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_assembly) { create(:assembly, parent: parent_assembly) }

    it "doesn't let the admin manage assemblies form other organizations" do
      within "table" do
        expect(page).not_to have_content(external_assembly.title["en"])
      end
    end
  end

  context "when the assembly has a scope" do
    let(:scope) { create(:scope, organization:) }

    before do
      assembly.update!(scopes_enabled: true, scope:)
    end

    it "disables the scope for the assembly" do
      click_link "Configure"

      uncheck :assembly_scopes_enabled

      expect(page).to have_selector("#assembly_scope_id.disabled")
      expect(page).to have_selector("#assembly_scope_id .picker-values div input[disabled]", visible: :all)

      within ".edit_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end

  it "shows the Assemblies link to manage nested assemblies" do
    expect(page).to have_link("Assemblies", href: decidim_admin_assemblies.assemblies_path(q: { parent_id_eq: assembly.id }))
  end
end
