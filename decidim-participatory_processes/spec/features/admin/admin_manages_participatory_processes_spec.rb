# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes", type: :feature do
  include_context "participatory process administration by admin"
  it_behaves_like "manage processes examples"
  it_behaves_like "manage processes announcements"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    @participatory_process_groups = create_list(:participatory_process_group, 3, organization: organization)
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "creating a participatory process" do
    before do
      within ".secondary-nav__actions" do
        page.find("a.button").click
      end
    end

    it "creates a new participatory process" do
      within ".new_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "My participatory process",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :participatory_process_subtitle,
          "#participatory_process-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :participatory_process_short_description,
          "#participatory_process-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :participatory_process_description,
          "#participatory_process-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        @group_name = @participatory_process_groups.first.name["en"]
        select @group_name, from: :participatory_process_participatory_process_group_id

        fill_in :participatory_process_slug, with: "slug"
        fill_in :participatory_process_hashtag, with: "#hashtag"
        attach_file :participatory_process_hero_image, image1_path
        attach_file :participatory_process_banner_image, image2_path

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within ".container" do
        expect(current_path).to eq decidim_admin_participatory_processes.participatory_process_steps_path(Decidim::ParticipatoryProcess.last)
        expect(page).to have_content("STEPS")
        expect(page).to have_content("Introduction")
      end
    end
  end

  context "updating a participatory process" do
    let!(:participatory_process3) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "update a participatory process without images does not delete them" do
      click_link translated(participatory_process3.title)
      click_submenu_link "Info"
      click_button "Update"

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_css("img[src*='#{participatory_process3.hero_image.url}']")
      expect(page).to have_css("img[src*='#{participatory_process3.banner_image.url}']")
    end
  end

  context "deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "deletes a participatory_process" do
      click_link translated(participatory_process2.title)
      accept_confirm { click_link "Destroy" }

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(participatory_process2.title))
      end
    end
  end
end
