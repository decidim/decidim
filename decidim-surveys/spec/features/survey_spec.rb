# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Answer a survey", type: :feature do
  include_context "feature"
  let(:manifest_name) { "surveys" }
  let(:title) do
    {
      "en" => "Survey's title",
      "ca" => "Títol de l'enquesta'",
      "es" => "Título de la encuesta"
    }
  end
  let(:description) do
    {
      "en" => "<p>Survey's content</p>",
      "ca" => "<p>Contingut de l'enquesta</p>",
      "es" => "<p>Contenido de la encuesta</p>"
    }
  end
  let(:user) { create(:user, :confirmed, organization: feature.organization) }
  let!(:survey) { create(:survey, feature: feature, title: title, description: description) }
  let!(:survey_question_1) { create(:survey_question, survey: survey) }
  let!(:survey_question_2) { create(:survey_question, survey: survey) }

  context "when the survey is not published" do
    it "the survey cannot be answered" do
      visit_feature

      expect(page).to have_i18n_content(survey.title)
      expect(page).to have_i18n_content(survey.description)

      expect(page).not_to have_content("ANSWER THE SURVEY")
      expect(page).not_to have_i18n_content(survey_question_1.body)
      expect(page).not_to have_i18n_content(survey_question_2.body)

      expect(page).to have_content("The survey is not published yet and cannot be answered.")
    end
  end

  context "when the survey is published" do
    before do
      survey.update_attributes(published_at: Time.current)
    end

    context "when the user is not logged in" do
      it "the survey cannot be answered" do
        visit_feature

        expect(page).to have_i18n_content(survey.title)
        expect(page).to have_i18n_content(survey.description)

        expect(page).to have_content("ANSWER THE SURVEY")
        expect(page).not_to have_i18n_content(survey_question_1.body)
        expect(page).not_to have_i18n_content(survey_question_2.body)
        expect(page).to have_content("Sign in with your account or sign up to answer the survey.")
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "the survey can be answered" do
        visit_feature

        expect(page).to have_i18n_content(survey.title)
        expect(page).to have_i18n_content(survey.description)

        expect(page).to have_content("ANSWER THE SURVEY")

        fill_in "survey_#{survey.id}_question_#{survey_question_1.id}_answer_body", with: "My first answer"
        fill_in "survey_#{survey.id}_question_#{survey_question_2.id}_answer_body", with: "My second answer"

        click_button "Submit"

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_content("You have already answered this survey.")
        expect(page).not_to have_content("ANSWER THE SURVEY")
        expect(page).not_to have_i18n_content(survey_question_1.body)
        expect(page).not_to have_i18n_content(survey_question_2.body)
      end
    end
  end
end
