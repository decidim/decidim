# frozen_string_literal: true

require "spec_helper"

describe "Admin manages consultations", type: :system do
  include_context "when administrating a consultation"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.consultations_path
  end

  describe "listing consultations" do
    let(:model_name) { consultation.class.model_name }
    let(:resource_controller) { Decidim::Consultations::Admin::ConsultationsController }

    it_behaves_like "filtering collection by published/unpublished"
  end

  describe "creating a consultation" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "creates a new consultation" do
      execute_script("$('#consultation_start_voting_date').focus()")
      find(".active").click

      execute_script("$('#consultation_end_voting_date').focus()")
      find(".active").click

      within ".new_consultation" do
        fill_in_i18n(
          :consultation_title,
          "#consultation-title-tabs",
          en: "My consultation",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :consultation_subtitle,
          "#consultation-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :consultation_description,
          "#consultation-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :consultation_slug, with: "slug"
      end

      dynamically_attach_file(:consultation_banner_image, image2_path)

      within ".new_consultation" do
        scope_pick select_data_picker(:consultation_decidim_highlighted_scope_id), organization.scopes.first
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_consultations.consultations_path
        expect(page).to have_content("My consultation")
      end
    end
  end

  describe "trying to create a consultation with invalid data" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "fails to create a new consultation" do
      execute_script("$('#consultation_start_voting_date').focus()")
      find(".active").click

      execute_script("$('#consultation_end_voting_date').focus()")
      find(".active").click

      within ".new_consultation" do
        fill_in_i18n(
          :consultation_title,
          "#consultation-title-tabs",
          en: "",
          es: "",
          ca: ""
        )
        fill_in_i18n(
          :consultation_subtitle,
          "#consultation-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :consultation_description,
          "#consultation-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :consultation_slug, with: "slug"
      end

      dynamically_attach_file(:consultation_banner_image, image2_path)

      within ".new_consultation" do
        scope_pick select_data_picker(:consultation_decidim_highlighted_scope_id), organization.scopes.first
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a consultation" do
    before do
      within find("tr", text: translated(consultation.title)) do
        click_link "Configure"
      end
    end

    it "updates a consultation" do
      fill_in_i18n(
        :consultation_title,
        "#consultation-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      dynamically_attach_file(:consultation_banner_image, image3_path, remove_before: true)

      within ".edit_consultation" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_selector("input[value='My new title']")
        expect(page).not_to have_css("img[src*='#{image2_filename}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  describe "updating a consultation with invalid values" do
    before do
      within find("tr", text: translated(consultation.title)) do
        click_link "Configure"
      end
    end

    it "do not updates the consultation" do
      fill_in_i18n(
        :consultation_title,
        "#consultation-title-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_consultation" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a consultation without images" do
    let!(:consultation3) { create(:consultation, organization:) }

    before do
      visit decidim_admin_consultations.consultations_path
    end

    it "update a consultation without images does not delete them" do
      within find("tr", text: translated(consultation3.title)) do
        click_link "Configure"
      end

      within ".edit_consultation" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_css("img[src*='#{consultation3.attached_uploader(:banner_image).path}']")
    end
  end

  describe "previewing consultations" do
    let!(:consultation) { create(:consultation, :unpublished, organization:) }

    it "allows the user to preview the unpublished consultation" do
      within find("tr", text: translated(consultation.title)) do
        preview_window = window_opened_by do
          click_link "Preview"
        end

        within_window(preview_window) do
          expect(page).to have_i18n_content(consultation.title)
          expect(page).to have_i18n_content(consultation.description)
        end
      end
    end
  end

  describe "viewing a missing consultation" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_consultations.consultation_path(99_999_999) }
    end
  end

  describe "publishing a consultation" do
    let!(:consultation) { create(:consultation, :unpublished, organization:) }

    before do
      within find("tr", text: translated(consultation.title)) do
        click_link "Configure"
      end
    end

    it "publishes the consultation" do
      click_link "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_consultations.edit_consultation_path(consultation)

      consultation.reload
      expect(consultation).to be_published
    end
  end

  describe "unpublishing a consultation" do
    let!(:consultation) { create(:consultation, :published, organization:) }

    before do
      within find("tr", text: translated(consultation.title)) do
        click_link "Configure"
      end
    end

    it "unpublishes the consultation" do
      click_link "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_consultations.edit_consultation_path(consultation)

      consultation.reload
      expect(consultation).not_to be_published
    end
  end

  context "when there are multiple organizations in the system" do
    let!(:external_consultation) { create(:consultation) }

    before do
      visit decidim_admin_consultations.consultations_path
    end

    it "doesn't let the admin manage assemblies form other organizations" do
      within "table" do
        expect(page).not_to have_content(external_consultation.title["en"])
      end
    end
  end
end
