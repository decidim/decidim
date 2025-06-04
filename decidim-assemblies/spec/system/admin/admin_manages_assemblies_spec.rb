# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies" do
  include_context "when admin administrating an assembly"
  include_context "with taxonomy filters context"

  let(:participatory_space_manifests) { ["assemblies"] }
  let!(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: another_root_taxonomy, participatory_space_manifests:) }
  let(:resource_controller) { Decidim::Assemblies::Admin::AssembliesController }
  let(:model_name) { assembly.class.model_name }

  context "when conditionally displaying private user menu entry" do
    let!(:my_space) { create(:assembly, organization:, private_space:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
      click_on translated(my_space.title)
    end

    context "when the participatory space is private" do
      let(:private_space) { true }

      it "hides the private user menu entry" do
        within_admin_sidebar_menu do
          expect(page).to have_content("Members")
        end
      end
    end

    context "when the participatory space is public" do
      let(:private_space) { false }

      it "shows the private user menu entry" do
        within_admin_sidebar_menu do
          expect(page).to have_no_content("Members")
        end
      end
    end
  end

  shared_examples "creating an assembly" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }
    let(:attributes) { attributes_for(:assembly, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }
    let(:last_assembly) { Decidim::Assembly.last }

    before do
      click_on "New assembly"
    end

    %w(purpose_of_action composition description short_description announcement internal_organisation).each do |field|
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='assembly-#{field}-tabs']", "full"
    end

    it_behaves_like "having a rich text editor for field", "#closing_date_reason_div", "content"
    it_behaves_like "having no taxonomy filters defined"

    it "creates a new assembly", versioning: true do
      within ".new_assembly" do
        fill_in_i18n(:assembly_title, "#assembly-title-tabs", **attributes[:title].except("machine_translations"))
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

        select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_weight, with: 1
      end

      dynamically_attach_file(:assembly_hero_image, image1_path)
      dynamically_attach_file(:assembly_banner_image, image2_path)

      within ".new_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(last_assembly.taxonomies).to contain_exactly(taxonomy)

      within "[data-content]" do
        expect(page).to have_current_path decidim_admin_assemblies.components_path(last_assembly)
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} assembly")
    end
  end

  shared_examples "updating an assembly" do
    let!(:assembly3) { create(:assembly, organization:) }

    before do
      visit decidim_admin_assemblies.assemblies_path
    end

    it "update a participatory process without images does not delete them" do
      within "tr", text: translated(assembly3.title) do
        click_on translated(assembly3.title)
      end

      within_admin_sidebar_menu do
        click_on "About this assembly"
      end

      select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

      click_on "Update"

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_select("taxonomies-#{taxonomy_filter.id}", selected: decidim_sanitize_translated(taxonomy.name))
      expect(page).to have_select("taxonomies-#{another_taxonomy_filter.id}", selected: "Please select an option")
      expect(assembly3.reload.taxonomies).to contain_exactly(taxonomy)

      hero_blob = assembly3.hero_image.blob
      within %([data-active-uploads] [data-filename="#{hero_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(hero_blob)
      end
    end
  end

  context "when managing parent assemblies" do
    let(:parent_assembly) { nil }
    let!(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
    it_behaves_like "updating an assembly"
    it_behaves_like "manage assemblies announcements"

    describe "listing parent assemblies" do
      it_behaves_like "filtering collection by published/unpublished"
      it_behaves_like "filtering collection by private/public"
    end
  end

  context "when navigating child assemblies" do
    let!(:parent_assembly) { create(:assembly, organization:) }
    let!(:child_assembly) { create(:assembly, :with_content_blocks, organization:, parent: parent_assembly, blocks_manifests: [:announcement]) }
    let(:assembly) { child_assembly }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    describe "listing child assemblies" do
      it "expands the parent assembly" do
        expect(page).to have_no_content(translated(child_assembly.title))

        within "tr", text: translated(parent_assembly.title) do
          find("a[data-arrow-down]").click
        end

        expect(page).to have_content(translated(child_assembly.title))

        within "tr", text: translated(parent_assembly.title) do
          find("a[data-arrow-up]").click
        end

        expect(page).to have_no_content(translated(child_assembly.title))
      end
    end
  end
end
