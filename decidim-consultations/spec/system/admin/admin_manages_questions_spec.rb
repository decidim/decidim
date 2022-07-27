# frozen_string_literal: true

require "spec_helper"

describe "Admin manages questions", type: :system do
  include_context "when administrating a consultation"

  describe "creating a question" do
    it "creates a new question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link("New question")

      within ".new_question" do
        fill_in_i18n_editor(
          :question_title,
          "#question-title-tabs",
          en: "My question"
        )
        fill_in_i18n(
          :question_subtitle,
          "#question-subtitle-tabs",
          en: "Subtitle"
        )
        fill_in_i18n(
          :question_promoter_group,
          "#question-promoter_group-tabs",
          en: "Promoter group"
        )
        fill_in_i18n(
          :question_participatory_scope,
          "#question-participatory_scope-tabs",
          en: "Participatory scope"
        )
        fill_in_i18n_editor(
          :question_question_context,
          "#question-question_context-tabs",
          en: "Context"
        )
        fill_in_i18n_editor(
          :question_what_is_decided,
          "#question-what_is_decided-tabs",
          en: "What is decided"
        )
        fill_in :question_slug, with: "slug"

        scope_pick select_data_picker(:question_decidim_scope_id), organization.scopes.first
      end

      dynamically_attach_file(:question_hero_image, image2_path)
      dynamically_attach_file(:question_banner_image, image1_path)

      within ".new_question" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_consultations.consultation_questions_path(consultation)
        expect(page).to have_content("My question")
      end
    end
  end

  describe "trying to create a question with invalid data" do
    it "fails to create a new question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link("New question")

      within ".new_question" do
        fill_in :question_slug, with: "slug"
        fill_in_i18n(
          :question_subtitle,
          "#question-subtitle-tabs",
          en: "Subtitle"
        )
        fill_in_i18n(
          :question_promoter_group,
          "#question-promoter_group-tabs",
          en: "Promoter group"
        )
        fill_in_i18n(
          :question_participatory_scope,
          "#question-participatory_scope-tabs",
          en: "Participatory scope"
        )
        fill_in_i18n_editor(
          :question_question_context,
          "#question-question_context-tabs",
          en: "Context"
        )
        fill_in_i18n_editor(
          :question_what_is_decided,
          "#question-what_is_decided-tabs",
          en: "What is decided"
        )
        scope_pick select_data_picker(:question_decidim_scope_id), organization.scopes.first
      end

      dynamically_attach_file(:question_banner_image, image1_path)
      dynamically_attach_file(:question_hero_image, image2_path)

      within ".new_question" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a question" do
    it "updates a question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)

      fill_in_i18n_editor(
        :question_title,
        "#question-title-tabs",
        en: "My new title"
      )
      dynamically_attach_file(:question_banner_image, image3_path, remove_before: true)

      within ".edit_question" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_content("My new title")
        expect(page).not_to have_css("img[src*='#{image2_filename}']")
        expect(page).to have_css("img[src*='#{image3_filename}']")
      end
    end
  end

  describe "updating a question with invalid values" do
    it "do not updates the question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)

      fill_in_i18n(
        :question_subtitle,
        "#question-subtitle-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_question" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating an question without images" do
    it "update a question without images does not deletes them" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)

      within ".edit_question" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_css("img[src*='#{question.attached_uploader(:banner_image).path}']")
      expect(page).to have_css("img[src*='#{question.attached_uploader(:hero_image).path}']")
    end
  end

  describe "deleting a question" do
    it "deletes the question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)
      accept_confirm { click_link "Delete" }

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(question.title))
      end
    end
  end

  describe "previewing questions" do
    it "allows the user to preview the question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)

      within find("tr", text: translated(question.title)) do
        preview_window = window_opened_by do
          click_link "Preview"
        end

        within_window(preview_window) do
          expect(page).to have_i18n_content(question.title)
          expect(page).to have_i18n_content(question.question_context)
        end
      end
    end
  end

  describe "viewing a missing question" do
    it_behaves_like "a 404 page" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
      end

      let(:target_path) { decidim_admin_consultations.question_path(99_999_999) }
    end
  end

  describe "publishing a question" do
    let!(:question) { create(:question, :unpublished, consultation:) }

    it "publishes the question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)
      click_link "Publish"
      expect(page).to have_content("successfully published")
      expect(page).to have_content("Unpublish")
      expect(page).to have_current_path decidim_admin_consultations.edit_question_path(question)

      question.reload
      expect(question).to be_published
    end
  end

  describe "unpublishing a question" do
    let!(:question) { create(:question, :published, consultation:) }

    it "unpublishes the question" do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_consultations.consultation_questions_path(consultation)
      click_link translated(question.title)
      click_link "Unpublish"
      expect(page).to have_content("successfully unpublished")
      expect(page).to have_content("Publish")
      expect(page).to have_current_path decidim_admin_consultations.edit_question_path(question)

      question.reload
      expect(question).not_to be_published
    end
  end
end
