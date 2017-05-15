# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Edit a survey", type: :feature do
  include_context "feature admin"
  let(:feature) { create(:surveys_feature, participatory_process: participatory_process) }
  let(:manifest_name) { feature.manifest_name }
  let!(:survey) { create(:survey, feature: feature) }

  it "updates the survey" do
    visit_feature_admin

    new_description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    within "form.edit_survey" do
      fill_in_i18n_editor(:survey_description, "#survey-description-tabs", new_description)
      click_button "Save"
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    visit_feature

    expect(page).to have_content("New description")
  end

  it "adds a few questions to the survey" do
    visit_feature_admin

    questions_body = [
      {
        en: "This is the first question",
        ca: "Aquesta es la primera pregunta",
        es: "Esta es la primera pregunta"
      },
      {
        en: "This is the second question",
        ca: "Aquesta es la segona pregunta",
        es: "Esta es la segunda pregunta"
      }
    ]

    within "form.edit_survey" do
      2.times { click_button "Add question" }

      expect(page).to have_selector('.survey-question', count: 2)

      page.all(".survey-question").each_with_index do |survey_question, idx|
        questions_body[idx].each do |locale, value|
          within survey_question do
            click_link I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
            fill_in "survey_questions__body_#{locale}", with: value
          end
        end
      end

      click_button "Save and publish"
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    visit_feature

    expect(page).to have_content("This is the first question")
    expect(page).to have_content("This is the second question")
  end

  describe "when a survey has an existing question" do
    let(:body) {
      {
        en: "This is the first question",
        ca: "Aquesta es la primera pregunta",
        es: "Esta es la primera pregunta"
      }
    }
    let!(:survey_question) { create(:survey_question, survey: survey, body: body) }

    it "modifies the question" do
      visit_feature_admin

      within "form.edit_survey" do
        expect(page).to have_selector('.survey-question', count: 1)

        within ".survey-question" do
          fill_in "survey_questions__body_en", with: "Modified question"
        end

        click_button "Save and publish"
      end

       within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      visit_feature

      expect(page).to have_content("Modified question")
      expect(page).not_to have_content("This is the first question")
    end
  end
end
