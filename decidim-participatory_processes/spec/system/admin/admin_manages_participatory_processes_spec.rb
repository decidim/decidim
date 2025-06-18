# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes", versioning: true do
  include_context "when admin administrating a participatory process"
  include_context "with taxonomy filters context"

  let(:participatory_space_manifests) { ["participatory_processes"] }
  let!(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: another_root_taxonomy, participatory_space_manifests:) }
  let!(:participatory_process_groups) do
    create_list(:participatory_process_group, 3, organization:)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "when conditionally displaying private user menu entry" do
    let!(:my_space) { create(:participatory_process, organization:, private_space:) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_processes_path
      click_on translated(my_space.title)
    end

    context "when the participatory process is private" do
      let(:private_space) { true }

      it "hides the private user menu entry" do
        within_admin_sidebar_menu do
          expect(page).to have_content("Members")
        end
      end
    end

    context "when the participatory process is public" do
      let(:private_space) { false }

      it "shows the private user menu entry" do
        within_admin_sidebar_menu do
          expect(page).to have_no_content("Members")
        end
      end
    end
  end

  it_behaves_like "manage processes examples"
  it_behaves_like "manage processes announcements"

  context "when creating a participatory process" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }
    let(:attributes) { attributes_for(:participatory_process, organization:) }
    let(:last_participatory_process) { Decidim::ParticipatoryProcess.last }

    before do
      click_on "New process"
    end

    %w(short_description description announcement).each do |field|
      it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='participatory_process-#{field}-tabs']", "full"
    end
    it_behaves_like "having no taxonomy filters defined"

    it "creates a new participatory process" do
      within ".new_participatory_process" do
        fill_in_i18n(:participatory_process_title, "#participatory_process-title-tabs", **attributes[:title].except("machine_translations"))
        fill_in_i18n(:participatory_process_subtitle, "#participatory_process-subtitle-tabs", **attributes[:subtitle].except("machine_translations"))
        fill_in_i18n_editor(:participatory_process_short_description, "#participatory_process-short_description-tabs", **attributes[:short_description].except("machine_translations"))
        fill_in_i18n_editor(:participatory_process_description, "#participatory_process-description-tabs", **attributes[:description].except("machine_translations"))
        fill_in_i18n_editor(:participatory_process_announcement, "#participatory_process-announcement-tabs", **attributes[:announcement].except("machine_translations"))

        fill_in_i18n(:participatory_process_developer_group, "#participatory_process-developer_group-tabs", **attributes[:developer_group].except("machine_translations"))
        fill_in_i18n(:participatory_process_local_area, "#participatory_process-local_area-tabs", **attributes[:local_area].except("machine_translations"))
        fill_in_i18n(:participatory_process_meta_scope, "#participatory_process-meta_scope-tabs", **attributes[:meta_scope].except("machine_translations"))
        fill_in_i18n(:participatory_process_target, "#participatory_process-target-tabs", **attributes[:target].except("machine_translations"))
        fill_in_i18n(:participatory_process_participatory_scope, "#participatory_process-participatory_scope-tabs", **attributes[:participatory_scope].except("machine_translations"))
        fill_in_i18n(:participatory_process_participatory_structure, "#participatory_process-participatory_structure-tabs", **attributes[:participatory_structure].except("machine_translations"))

        group_title = participatory_process_groups.first.title["en"]
        select group_title, from: :participatory_process_participatory_process_group_id

        select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

        fill_in :participatory_process_slug, with: "slug"
        fill_in :participatory_process_hashtag, with: "#hashtag"
        fill_in :participatory_process_weight, with: 1
      end

      dynamically_attach_file(:participatory_process_hero_image, image1_path)

      within ".new_participatory_process" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(last_participatory_process.taxonomies).to contain_exactly(taxonomy)

      within "[data-content]" do
        expect(page).to have_current_path decidim_admin_participatory_processes.participatory_process_steps_path(Decidim::ParticipatoryProcess.last)
        expect(page).to have_content("Phases")
        expect(page).to have_content("Introduction")
      end

      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} participatory process")
    end
  end

  context "when updating a participatory process" do
    let!(:participatory_process3) { create(:participatory_process, organization:) }
    let(:attributes) { attributes_for(:participatory_process, organization:) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "update a participatory process without images does not delete them" do
      within "tr", text: translated(participatory_process3.title) do
        click_on translated(participatory_process3.title)
      end

      within_admin_sidebar_menu do
        click_on "About this process"
      end

      select(decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}")

      click_on "Update"

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_select("taxonomies-#{taxonomy_filter.id}", selected: decidim_sanitize_translated(taxonomy.name))
      expect(page).to have_select("taxonomies-#{another_taxonomy_filter.id}", selected: "Please select an option")
      expect(participatory_process3.reload.taxonomies).to contain_exactly(taxonomy)

      hero_blob = participatory_process3.hero_image.blob
      within %([data-active-uploads] [data-filename="#{hero_blob.filename}"]) do
        src = page.find("img")["src"]
        expect(src).to be_blob_url(hero_blob)
      end
    end
  end
end
