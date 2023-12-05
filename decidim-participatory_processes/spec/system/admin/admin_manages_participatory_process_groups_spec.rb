# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process groups" do
  include_context "when admin administrating a participatory process"

  let!(:participatory_processes) do
    create_list(:participatory_process, 3, organization:)
  end

  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) { Decidim::Dev.asset(image1_filename) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_process_groups_path
  end

  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='participatory_process_group-description-tabs']", "full" do
    before do
      within "div.process-title" do
        click_link "New process group"
      end
    end
  end

  it "creates a new participatory process group" do
    within "div.process-title" do
      click_link "New process group"
    end

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
    end

    dynamically_attach_file(:participatory_process_group_hero_image, image1_path)

    within ".new_participatory_process_group" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_field(:participatory_process_group_title_en, with: "My group")
    expect(page).to have_field(:participatory_process_group_hashtag, with: "hashtag")
    expect(page).to have_field(:participatory_process_group_group_url, with: "http://example.org")
    expect(page).to have_field(:participatory_process_group_developer_group_en, with: "X corporation")
    expect(page).to have_select("Related processes", selected: participatory_processes.first.title["en"])
    expect(page).to have_css("img[src*='#{image1_filename}']")
  end

  context "with existing groups" do
    let!(:participatory_processes) { create_list(:participatory_process, 3, organization:) }
    let!(:participatory_process_group) { create(:participatory_process_group, organization:) }

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
      end

      dynamically_attach_file(:participatory_process_group_hero_image, image2_path, remove_before: true)

      within ".edit_participatory_process_group" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_field(:participatory_process_group_title_en, with: "My old group")
      expect(page).to have_content("New description")
      expect(page).to have_field(:participatory_process_group_hashtag, with: "new_hashtag")
      expect(page).to have_field(:participatory_process_group_group_url, with: "http://new-example.org")
      expect(page).to have_field(:participatory_process_group_developer_group_en, with: "Z corporation")
      expect(page).to have_select("Related processes", selected: participatory_processes.last.title["en"])
      expect(page).to have_css("img[src*='#{image2_filename}']")
    end

    it "validates the group attributes" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      within ".edit_participatory_process_group" do
        fill_in_i18n(
          :participatory_process_group_title,
          "#participatory_process_group-title-tabs",
          en: "",
          es: "",
          ca: ""
        )

        find("*[type=submit]").click
      end

      expect(page).to have_content("There was a problem updating this participatory process group")
    end

    it "can remove its image" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      within ".upload-container-for-hero_image" do
        find_by_id("participatory_process_group_hero_image_button").click
      end

      click_button "Remove"
      click_button "Next"

      click_button "Update"

      expect(page).not_to have_css("img")
    end

    it "can delete them" do
      within find("tr", text: participatory_process_group.title["en"]) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(participatory_process_group.title["en"])
      end
    end

    it "has a link to the landing page" do
      within find("tr", text: participatory_process_group.title["en"]) do
        click_link "Edit"
      end

      click_button "Manage"
      click_link "Landing page"

      expect(page).to have_content "Active content blocks"
    end
  end

  context "when rendering the main menu" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    context "when within participatory processes" do
      it "there is a tab which renders the participatory process group link" do
        within "[data-content] .main-nav" do
          within(".tab-x-container li", text: "Process groups") do
            expect(page).to have_selector(:link_or_button, "Process groups")
          end
        end
      end
    end
  end
end
