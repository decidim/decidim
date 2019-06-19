# frozen_string_literal: true

require "spec_helper"

describe "Admin manages responses", type: :system do
  include_context "when administrating a consultation"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.responses_path(question)
  end

  describe "creating a response" do
    before do
      click_link("New response")
    end

    it "creates a new response" do
      within ".new_response" do
        fill_in_i18n(
          :response_title,
          "#response-title-tabs",
          en: "My response",
          es: "Mi respuesta",
          ca: "La meua resposta"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_consultations.responses_path(question)
        expect(page).to have_content("My response")
      end
    end
  end

  describe "trying to create a response with invalid data" do
    before do
      click_link("New response")
    end

    it "fails to create a new response" do
      within ".new_response" do
        fill_in_i18n(
          :response_title,
          "#response-title-tabs",
          en: "",
          es: "",
          ca: ""
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a response" do
    before do
      click_link translated(response.title)
    end

    it "updates a response" do
      fill_in_i18n(
        :response_title,
        "#response-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      within ".edit_response" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_consultations.responses_path(question)
      end
    end
  end

  describe "updating a response with invalid values" do
    before do
      click_link translated(response.title)
    end

    it "do not updates the response" do
      fill_in_i18n(
        :response_title,
        "#response-title-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_response" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "deleting a response" do
    before do
      click_link translated(response.title)
    end

    it "deletes the response" do
      accept_confirm { click_link "Delete" }

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(response.title))
      end
    end
  end
end
