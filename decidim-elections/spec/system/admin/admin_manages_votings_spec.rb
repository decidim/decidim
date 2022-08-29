# frozen_string_literal: true

require "spec_helper"

describe "Admin manages votings", type: :system do
  include_context "when admin managing a voting"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.votings_path
  end

  describe "when listing votings" do
    let(:model_name) { voting.class.model_name }
    let(:resource_controller) { Decidim::Votings::Admin::VotingsController }

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
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#voting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
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
      end

      dynamically_attach_file(:voting_banner_image, image1_path)
      dynamically_attach_file(:voting_introductory_image, image2_path)

      within ".new_voting" do
        select "Online", from: :voting_voting_type
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
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#voting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
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
        select "Online", from: :voting_voting_type
      end

      dynamically_attach_file(:voting_banner_image, image1_path)
      dynamically_attach_file(:voting_introductory_image, image2_path)

      within ".new_voting" do
        scope_pick select_data_picker(:voting_scope_id), organization.scopes.first
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a voting" do
    let(:elections_component) { create(:elections_component, participatory_space: voting) }

    before do
      click_link translated(voting.title)
    end

    it "updates a voting" do
      create(:election, component: elections_component)

      fill_in_i18n(
        :voting_title,
        "#voting-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      dynamically_attach_file(:voting_banner_image, image3_path, remove_before: true)
      select "Online", from: :voting_voting_type

      within ".edit_voting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).not_to have_admin_callout("You don't have any election configured")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).not_to have_css("img[src*='#{image2_filename}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  describe "updating a voting with invalid values" do
    before do
      click_link translated(voting.title)
    end

    it "does not update the voting" do
      fill_in_i18n(
        :voting_title,
        "#voting-title-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_voting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a voting with invalid image" do
    before do
      click_link translated(voting.title)
    end

    it "shows an error inside the upload modal" do
      find("#voting_banner_image_button").click

      within ".upload-modal" do
        find(".remove-upload-item").click
        input_element = find("input[type='file']", visible: :all)
        input_element.attach_file(image_invalid_path)

        expect(page).to have_content("file should be one of image/jpeg, image/png", count: 1)
        expect(page).to have_css(".upload-errors .form-error", count: 1)
      end
    end
  end

  describe "updating a voting without images" do
    let!(:voting3) { create(:voting, organization:) }

    before do
      visit decidim_admin_votings.votings_path
    end

    it "does not delete them" do
      click_link translated(voting3.title)

      within ".edit_voting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_css("img[src*='#{voting3.attached_uploader(:banner_image).path}']")
    end
  end

  describe "previewing votings" do
    let!(:voting) { create(:voting, :unpublished, organization:) }

    it "allows the user to preview the unpublished voting" do
      within find("tr", text: translated(voting.title)) do
        preview_window = window_opened_by do
          click_link "Preview"
        end

        within_window(preview_window) do
          expect(page).to have_i18n_content(voting.title)
          expect(page).to have_i18n_content(voting.description)
        end
      end
    end
  end

  describe "viewing a missing voting" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_votings.voting_path(99_999_999) }
    end
  end

  describe "publishing a voting" do
    let!(:voting) { create(:voting, :unpublished, organization:) }

    before do
      click_link translated(voting.title)
    end

    it "publishes the voting" do
      click_link "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_votings.edit_voting_path(voting)

      voting.reload
      expect(voting).to be_published
    end
  end

  describe "unpublishing a voting" do
    let!(:voting) { create(:voting, :published, organization:) }

    before do
      click_link translated(voting.title)
    end

    it "unpublishes the voting" do
      click_link "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_votings.edit_voting_path(voting)

      voting.reload
      expect(voting).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_voting) { create(:voting) }

    before do
      visit decidim_admin_votings.votings_path
    end

    it "doesn't let the admin manage votings from other organizations" do
      within "table" do
        expect(page).not_to have_content(external_voting.title["en"])
      end
    end
  end

  it "renders the sub nav to manage voting's settings" do
    within ".table-list" do
      click_link translated(voting.title)
    end

    within ".secondary-nav--subnav" do
      expect(page).to have_content("Information")
      expect(page).to have_content("Landing Page")
      expect(page).to have_content("Components")
      expect(page).to have_content("Attachments")
      expect(page).to have_content("Polling Stations")
      expect(page).to have_content("Polling Officers")
      expect(page).to have_css(".is-active", text: "Information")
    end
  end
end
