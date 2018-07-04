# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conferences", type: :system do
  include_context "when admin administrating a conference"

  shared_examples "creating an conference" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      click_link "New conference"
    end

    it "creates a new conference" do
      within ".new_conference" do
        fill_in_i18n(
          :conference_title,
          "#conference-title-tabs",
          en: "My conference",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :conference_slogan,
          "#conference-slogan-tabs",
          en: "Slogan",
          es: "Eslogan",
          ca: "Eslógan"
        )
        fill_in_i18n_editor(
          :conference_short_description,
          "#conference-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :conference_description,
          "#conference-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in :conference_slug, with: "slug"
        fill_in :conference_hashtag, with: "#hashtag"
        attach_file :conference_hero_image, image1_path
        attach_file :conference_banner_image, image2_path

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_conferences.conferences_path
        expect(page).to have_content("My conference")
      end
    end
  end

  shared_examples "deleting an conference" do
    before do
      click_link translated(conference.title)
    end

    it "deletes an conference" do
      accept_confirm { click_link "Delete" }

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(conference.title))
      end
    end
  end
end
