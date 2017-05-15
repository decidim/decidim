# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Edit a survey", type: :feature do
  include_context "feature admin"
  let(:feature) { create(:surveys_feature, participatory_process: participatory_process) }
  let(:manifest_name) { feature.manifest_name }

  before do
    create(:survey, feature: feature)
    visit_feature_admin
  end

  it "updates the survey" do
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
end
