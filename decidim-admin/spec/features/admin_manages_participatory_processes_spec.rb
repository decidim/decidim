# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

describe "Admin manage participatory processes", type: :feature do
  include_context "participatory process admin"
  it_behaves_like "manage processes examples"
  let (:participatory_processes_groups) { create_list(:participatory_process_group, 3, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  it "creates a new participatory_process" do
    find(".actions .new").click

    within ".new_participatory_process" do
      fill_in_i18n(
        :participatory_process_title,
        "#title-tabs",
        en: "My participatory process",
        es: "Mi proceso participativo",
        ca: "El meu procés participatiu"
      )
      fill_in_i18n(
        :participatory_process_subtitle,
        "#subtitle-tabs",
        en: "Subtitle",
        es: "Subtítulo",
        ca: "Subtítol"
      )
      fill_in_i18n_editor(
        :participatory_process_short_description,
        "#short_description-tabs",
        en: "Short description",
        es: "Descripción corta",
        ca: "Descripció curta"
      )
      fill_in_i18n_editor(
        :participatory_process_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      select participatory_process_groups.first.title["en"], from: :participatory_process_group_id

      fill_in :participatory_process_slug, with: "slug"
      fill_in :participatory_process_hashtag, with: "#hashtag"
      attach_file :participatory_process_hero_image, image1_path
      attach_file :participatory_process_banner_image, image2_path

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within ".tabs-content" do
      expect(page).to have_content("My participatory process")
      expect(page).to have_css("img[src*='#{image1_filename}']")
      expect(page).to have_css("img[src*='#{image2_filename}']")
    end
  end

  context "deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "deletes a participatory_process" do
      click_link translated(participatory_process2.title)
      click_processes_menu_link "Settings"
      click_link "Destroy"

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(participatory_process2.title))
      end
    end
  end
end
