# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", type: :system do
  include_context "when admin administrating an assembly"

  let(:model_name) { assembly.class.model_name }
  let(:resource_controller) { Decidim::Assemblies::Admin::AssembliesController }

  shared_examples "creating an assembly" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }
    let(:attributes) { attributes_for(:assembly, organization: organization) }

    before do
      click_link "New assembly"
    end

    %w(purpose_of_action composition description short_description announcement internal_organisation).each do |field|
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='assembly-#{field}-tabs']", "full"
    end

    it_behaves_like "having a rich text editor for field", "#closing_date_reason_div", "content"

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

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        fill_in :assembly_weight, with: 1
      end

      dynamically_attach_file(:assembly_hero_image, image1_path)
      dynamically_attach_file(:assembly_banner_image, image2_path)

      within ".new_assembly" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_assemblies.assemblies_path(q: { parent_id_eq: parent_assembly&.id })
        expect(page).to have_content(translated(attributes[:title]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} assembly")
    end
  end

  context "when managing parent assemblies" do
    let(:parent_assembly) { nil }
    let!(:assembly) { create :assembly, organization: organization }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
    it_behaves_like "manage assemblies announcements"

    describe "listing parent assemblies" do
      it_behaves_like "filtering collection by published/unpublished"
      it_behaves_like "filtering collection by private/public"

      context "when filtering by assemblies type" do
        include_context "with filterable context"

        let!(:assemblies_type1) { create(:assemblies_type) }
        let!(:assemblies_type2) { create(:assemblies_type) }

        Decidim::AssembliesType.all.each do |assemblies_type|
          i18n_assemblies_type = assemblies_type.name[I18n.locale.to_s]

          context "filtering collection by assemblies_type: #{i18n_assemblies_type}" do
            let!(:assembly1) { create(:assembly, organization: organization, assemblies_type: assemblies_type1) }
            let!(:assembly2) { create(:assembly, organization: organization, assemblies_type: assemblies_type2) }

            it_behaves_like "a filtered collection", options: "Assembly type", filter: i18n_assemblies_type do
              let(:in_filter) { translated(assembly_with_type(type).title) }
              let(:not_in_filter) { translated(assembly_without_type(type).title) }
            end
          end
        end

        it_behaves_like "paginating a collection"

        def assembly_with_type(type)
          Decidim::Assembly.find_by(decidim_assemblies_type_id: type)
        end

        def assembly_without_type(type)
          Decidim::Assembly.where.not(decidim_assemblies_type_id: type).sample
        end
      end
    end
  end

  context "when managing child assemblies" do
    let!(:parent_assembly) { create :assembly, organization: organization }
    let!(:child_assembly) { create :assembly, organization: organization, parent: parent_assembly }
    let(:assembly) { child_assembly }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
      within find("tr", text: translated(parent_assembly.title)) do
        click_link "Assemblies"
      end
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
    it_behaves_like "manage assemblies announcements"

    describe "listing child assemblies" do
      it_behaves_like "filtering collection by published/unpublished" do
        let!(:published_space) { child_assembly }
        let!(:unpublished_space) { create(:assembly, :unpublished, parent: parent_assembly, organization: organization) }
      end

      it_behaves_like "filtering collection by private/public" do
        let!(:public_space) { child_assembly }
        let!(:private_space) { create(:assembly, :private, parent: parent_assembly, organization: organization) }
      end
    end
  end
end
