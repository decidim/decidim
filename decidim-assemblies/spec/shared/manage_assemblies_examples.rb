# frozen_string_literal: true

shared_examples "manage assemblies" do
  describe "updating an assembly" do
    let(:image3_filename) { "city3.jpeg" }
    let(:image3_path) { Decidim::Dev.asset(image3_filename) }

    let(:assembly_parent_id_options) { page.find_by_id("assembly_parent_id").find_all("option").map(&:value) }
    let(:attributes) { attributes_for(:assembly, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }

    before do
      click_on "Configure"
    end

    it "updates an assembly" do
      fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))

      dynamically_attach_file(:assembly_banner_image, image3_path, remove_before: true)

      within ".edit_assembly" do
        expect(assembly_parent_id_options).not_to include(assembly.id)
        fill_in_i18n(:assembly_subtitle, "#assembly-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:assembly_short_description, "#assembly-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_description, "#assembly-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:assembly_purpose_of_action, "#assembly-purpose_of_action-tabs", **attributes[:purpose_of_action].except("machine_translations"))
        fill_in_i18n_editor(:assembly_composition, "#assembly-composition-tabs", **attributes[:composition].except("machine_translations"))
        fill_in_i18n_editor(:assembly_internal_organisation, "#assembly-internal_organisation-tabs", **attributes[:internal_organisation].except("machine_translations"))
        fill_in_i18n_editor(:assembly_announcement, "#assembly-announcement-tabs", **attributes[:announcement].except("machine_translations"))
        fill_in_i18n_editor(:assembly_closing_date_reason, "#assembly-closing_date_reason-tabs", **attributes[:closing_date_reason].except("machine_translations"))

        fill_in_i18n(:assembly_participatory_scope, "#assembly-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:assembly_participatory_structure, "#assembly-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))
        fill_in_i18n(:assembly_meta_scope, "#assembly-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:assembly_local_area, "#assembly-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:assembly_target, "#assembly-target-tabs", **attributes[:target].except("machine_translations"))

        fill_in :assembly_creation_date_date, with: nil, fill_options: { clear: :backspace }
        fill_in :assembly_included_at_date, with: nil, fill_options: { clear: :backspace }
        fill_in :assembly_duration_date, with: nil, fill_options: { clear: :backspace }
        fill_in :assembly_closing_date_date, with: nil, fill_options: { clear: :backspace }
        fill_in_datepicker :assembly_creation_date_date, with: Date.yesterday.strftime("%d/%m/%Y")
        fill_in_datepicker :assembly_included_at_date, with: Date.current.strftime("%d/%m/%Y")
        fill_in_datepicker :assembly_duration_date, with: Date.tomorrow.strftime("%d/%m/%Y")
        fill_in_datepicker :assembly_closing_date_date, with: Date.tomorrow.strftime("%d/%m/%Y")
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "[data-content]" do
        expect(page).to have_css("input[value='#{translated(attributes[:title])}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
        expect(page).to have_field(:assembly_creation_date_date, with: Date.yesterday.strftime("%d/%m/%Y").to_s)
        expect(page).to have_field(:assembly_included_at_date, with: Date.current.strftime("%d/%m/%Y").to_s)
        expect(page).to have_field(:assembly_duration_date, with: Date.tomorrow.strftime("%d/%m/%Y").to_s)
        expect(page).to have_field(:assembly_closing_date_date, with: Date.tomorrow.strftime("%d/%m/%Y").to_s)
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} assembly")
    end
  end

  describe "updating an assembly without images" do
    before do
      within "tr", text: translated(assembly.title) do
        click_on "Configure"
      end
    end

    it "update an assembly without images does not delete them" do
      within_admin_sidebar_menu do
        click_on "About this assembly"
      end
      click_on "Update"

      expect(page).to have_admin_callout("successfully")

      hero_blob = assembly.hero_image.blob
      within %([data-active-uploads] [data-filename="#{hero_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(hero_blob)
      end

      banner_blob = assembly.hero_image.blob
      within %([data-active-uploads] [data-filename="#{banner_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(banner_blob)
      end
    end
  end

  describe "previewing assemblies" do
    context "when the assembly is unpublished" do
      let!(:assembly) { create(:assembly, :unpublished, :with_content_blocks, organization:, parent: parent_assembly) }

      it "allows the user to preview the unpublished assembly" do
        new_window = window_opened_by do
          within "tr", text: translated(assembly.title) do
            click_on "Preview"
          end
        end

        page.within_window(new_window) do
          within(".participatory-space__container") do
            expect(page).to have_content(translated(assembly.title))
          end
        end
      end
    end

    context "when the assembly is published" do
      let!(:assembly) { create(:assembly, organization:, parent: parent_assembly) }

      it "allows the user to preview the unpublished assembly" do
        new_window = window_opened_by do
          within "tr", text: translated(assembly.title) do
            click_on "Preview"
          end
        end

        page.within_window(new_window) do
          expect(page).to have_current_path decidim_assemblies.assembly_path(assembly, locale: I18n.locale)
          expect(page).to have_content(translated(assembly.title))
        end
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
      within "tr", text: translated(assembly.title) do
        click_on "Configure"
      end
    end

    it "publishes the assembly" do
      click_on "Publish"
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
      within "tr", text: translated(assembly.title) do
        click_on "Configure"
      end
    end

    it "unpublishes the assembly" do
      click_on "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_assemblies.edit_assembly_path(assembly)

      assembly.reload
      expect(assembly).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_assembly) { create(:assembly, parent: parent_assembly) }

    it "does not let the admin manage assemblies form other organizations" do
      within "table" do
        expect(page).to have_no_content(external_assembly.title["en"])
      end
    end
  end
end
