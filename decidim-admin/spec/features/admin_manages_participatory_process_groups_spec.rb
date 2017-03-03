# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

describe "Admin manage participatory process groups", type: :feature do
  include_context "participatory process admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    @participatory_processes = create_list(:participatory_process, 3, organization: organization)
    visit decidim_admin.participatory_process_groups_path
  end

  it "creates a new participatory process group" do
    find(".actions .new").click

    within ".new_participatory_process_group" do
      fill_in_i18n(
        :participatory_process_group_name,
        "#name-tabs",
        en: "My group",
        es: "Mi grupo",
        ca: "El meu grup"
      )
      fill_in_i18n_editor(
        :participatory_process_group_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      select @participatory_processes.first.title["en"], from: :participatory_process_group_participatory_process_ids
      attach_file :participatory_process_group_hero_image, image1_path

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
end
