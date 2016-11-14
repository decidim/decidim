# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/manage_processes_examples"

describe "Admin manage participatory processes", type: :feature do
  it_behaves_like "manage processes examples"

  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end
  let(:image1_filename) { "city.jpeg" }
  let(:image1_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image1_filename)
  end
  let(:image2_filename) { "city2.jpeg" }
  let(:image2_path) do
    File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", image2_filename)
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
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
      fill_in_i18n(
        :participatory_process_short_description,
        "#short_description-tabs",
        en: "Short description",
        es: "Descripción corta",
        ca: "Descripció curta"
      )
      fill_in_i18n(
        :participatory_process_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :participatory_process_slug, with: "slug"
      fill_in :participatory_process_hashtag, with: "#hashtag"
      attach_file :participatory_process_hero_image, image1_path
      attach_file :participatory_process_banner_image, image2_path

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My participatory process")
      click_link("My participatory process")
    end

    within "dl" do
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
      click_link "Destroy"

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(participatory_process2.title))
      end
    end
  end
end
