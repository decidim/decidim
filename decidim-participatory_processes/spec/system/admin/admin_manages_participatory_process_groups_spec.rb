# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process groups", type: :system do
  include_context "when admin administrating a participatory process"

  let!(:participatory_processes) do
    create_list(:participatory_process, 3, organization: organization)
  end

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_process_groups_path
  end

  it "creates a new participatory process group" do
    find(".card-title .new").click

    within ".new_participatory_process_group" do
      fill_in_i18n(
        :participatory_process_group_title,
        "#participatory_process_group-title-tabs",
        en: "My group",
        es: "Mi grupo",
        ca: "El meu grup"
      )
      fill_in_i18n_editor(
        :participatory_process_group_description,
        "#participatory_process_group-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in :participatory_process_group_hashtag, with: "hashtag"
      fill_in :participatory_process_group_group_url, with: "http://example.org"
      fill_in_i18n(
        :participatory_process_group_developer_group,
        "#participatory_process_group-developer_group-tabs",
        en: "X corporation",
        es: "La corporación X",
        ca: "La corporació X"
      )
      select participatory_processes.first.title["en"], from: :participatory_process_group_participatory_process_ids
      attach_file :participatory_process_group_hero_image, image1_path

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_content("My group")
    expect(page).to have_content("hashtag")
    expect(page).to have_content("http://example.org")
    expect(page).to have_content("X corporation")
    expect(page).to have_content(participatory_processes.first.title["en"])
    expect(page).to have_css("img[src*='#{image1_filename}']")
  end

  context "with existing groups" do
    let!(:participatory_processes) { create_list(:participatory_process, 3, organization: organization) }
    let!(:participatory_process_group) { create(:participatory_process_group, organization: organization) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      visit current_path
    end

    it "can edit them" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      within ".edit_participatory_process_group" do
        fill_in_i18n(
          :participatory_process_group_title,
          "#participatory_process_group-title-tabs",
          en: "My old group",
          es: "Mi grupo antiguo",
          ca: "El meu grup antic"
        )
        fill_in_i18n_editor(
          :participatory_process_group_description,
          "#participatory_process_group-description-tabs",
          en: "New description",
          es: "Nueva descripción",
          ca: "Nova descripció"
        )
        fill_in :participatory_process_group_hashtag, with: "new_hashtag"
        fill_in :participatory_process_group_group_url, with: "http://new-example.org"
        fill_in_i18n(
          :participatory_process_group_developer_group,
          "#participatory_process_group-developer_group-tabs",
          en: "Z corporation",
          es: "La corporación Z",
          ca: "La corporació Z"
        )
        select participatory_processes.last.title["en"], from: :participatory_process_group_participatory_process_ids
        attach_file :participatory_process_group_hero_image, image2_path

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My old group")
      expect(page).to have_content("New description")
      expect(page).to have_content("new_hashtag")
      expect(page).to have_content("http://new-example.org")
      expect(page).to have_content("Z corporation")
      expect(page).to have_content(participatory_processes.last.title["en"])
      expect(page).to have_css("img[src*='#{image2_filename}']")
    end

    it "can remove its image" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      check "Remove this file"
      click_button "Update"

      expect(page).to have_no_css("img")
    end

    it "can delete them" do
      within find("tr", text: participatory_process_group.title["en"]) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(participatory_process_group.title["en"])
      end
    end

    it "has sub nav with Info active by default" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      within "div.secondary-nav" do
        expect(page).to have_content("Info")
        expect(page).to have_content("Landing page")
        active_secondary_nav = find(:xpath, ".//li[@class='is-active']")
        expect(active_secondary_nav.text).to eq("Info")
      end
    end
  end

  context "when rendering the main menu" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "doesn't show the participatory process group link" do
      within ".main-nav" do
        expect(page).not_to have_selector(:link_or_button, "Process groups")
      end
    end

    context "when within participatory processes" do
      it "the secondary nav renders the participatory process group link" do
        within ".secondary-nav" do
          expect(page).to have_selector(:link_or_button, "Process groups")
        end
      end
    end
  end
end
