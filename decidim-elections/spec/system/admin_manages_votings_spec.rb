# frozen_string_literal: true

require "spec_helper"

describe "Admin manages votings", type: :system do
  include_context "when administrating a voting"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.votings_path
  end

  describe "listing votings" do
    let(:model_name) { voting.class.model_name }

    it_behaves_like "filtering collection by published/unpublished"
  end

  describe "creating a voting" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "creates a new voting" do
      page.execute_script("$('#voting_start_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#voting_end_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      within ".new_voting" do
        fill_in_i18n(
          :voting_title,
          "#voting-title-tabs",
          en: "My voting",
          es: "Mi votación",
          ca: "La meva votació"
        )
        fill_in_i18n_editor(
          :voting_description,
          "#voting-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :voting_slug, with: "slug"
        attach_file :voting_banner_image, image1_path
        attach_file :voting_introductory_image, image2_path

        scope_pick select_data_picker(:voting_scope_id), organization.scopes.first

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_votings.votings_path
        expect(page).to have_content("My voting")
      end
    end
  end

  describe "trying to create a voting with invalid data" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "fails to create a new voting" do
      page.execute_script("$('#voting_start_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#voting_end_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      within ".new_voting" do
        fill_in_i18n(
          :voting_title,
          "#voting-title-tabs",
          en: "",
          es: "",
          ca: ""
        )
        fill_in_i18n_editor(
          :voting_description,
          "#voting-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :voting_slug, with: "slug"
        attach_file :voting_banner_image, image1_path
        attach_file :voting_introductory_image, image2_path
        scope_pick select_data_picker(:voting_scope_id), organization.scopes.first

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end
end
