# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "edit surveys" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

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

  context "when the survey is not already answered" do
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

        expect(page).to have_selector(".survey-question", count: 2)

        page.all(".survey-question").each_with_index do |survey_question, idx|
          questions_body[idx].each do |locale, value|
            within survey_question do
              click_link I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
              find("input[name='survey[questions][][body_#{locale}]']").send_keys value
            end
          end
        end

        click_button "Save"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      visit_feature_admin

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the second question']")
    end

    it "adds a question with answer options" do
      visit_feature_admin

      question_body = {
        en: "This is the first question",
        ca: "Aquesta es la primera pregunta",
        es: "Esta es la primera pregunta"
      }

      answer_options_body = [
        {
          en: "This is the first option",
          ca: "Aquesta es la primera opció",
          es: "Esta es la primera opción"
        },
        {
          en: "This is the second option",
          ca: "Aquesta es la segona opció",
          es: "Esta es la segunda opción"
        }
      ]

      within "form.edit_survey" do
        click_button "Add question"

        expect(page).to have_selector(".survey-question", count: 1)

        question_body.each do |locale, value|
          within ".survey-question" do
            click_link I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
            find("input[name='survey[questions][][body_#{locale}]']").send_keys value
          end
        end

        expect(page).not_to have_content "Add answer option"

        select "Single option", from: "Type"

        expect(page).to have_content "Add answer option"

        2.times { click_button "Add answer option" }

        page.all(".survey-question-answer-option").each_with_index do |survey_question_answer_option, idx|
          answer_options_body[idx].each do |locale, value|
            within survey_question_answer_option do
              click_link I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
              find("input[name='survey[questions][][answer_options][][body_#{locale}]']").send_keys value
            end
          end
        end

        click_button "Save"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      visit_feature_admin

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the first option']")
      expect(page).to have_selector("input[value='This is the second option']")
    end

    describe "when a survey has an existing question" do
      let!(:survey_question) { create(:survey_question, survey: survey, body: body) }

      it "modifies the question" do
        visit_feature_admin

        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 1)

          within ".survey-question" do
            fill_in "survey-question-#{survey_question.id}_body_en", with: "Modified question"
            check "Mandatory"
            select "Long answer", from: "Type"
          end

          click_button "Save"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        visit_feature_admin

        expect(page).to have_selector("input[value='Modified question']")
        expect(page).not_to have_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#survey_questions_#{survey_question.id}_mandatory[checked]")
        expect(page).to have_selector("select#survey_questions_#{survey_question.id}_question_type option[value='long_answer'][selected]")
      end

      it "removes the question" do
        visit_feature_admin

        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 1)

          within ".survey-question" do
            click_button "Remove question"
          end

          click_button "Save"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        visit_feature_admin

        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 0)
        end
      end
    end
  end

  context "when the survey is already answered" do
    let!(:survey_question) { create(:survey_question, survey: survey, body: body) }
    let!(:survey_answer) { create(:survey_answer, survey: survey, question: survey_question) }

    it "cannot modify survey questions" do
      visit_feature_admin

      expect(page).not_to have_content("Add question")
      expect(page).not_to have_content("Remove question")
      expect(page).to have_selector("input[value='This is the first question'][disabled]")
    end
  end
end
