# frozen_string_literal: true

require "spec_helper"

describe "Answer a survey", type: :feature do
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
  let!(:survey_question_1) { create(:survey_question, survey: survey, position: 1) }
  let!(:survey_question_2) { create(:survey_question, survey: survey, position: 0) }

  include_context "feature"

  context "when the survey doesn't allow answers" do
    it "the survey cannot be answered" do
      visit_feature

      expect(page).to have_i18n_content(survey.title, upcase: true)
      expect(page).to have_i18n_content(survey.description)

      expect(page).to have_no_i18n_content(survey_question_1.body)
      expect(page).to have_no_i18n_content(survey_question_2.body)

      expect(page).to have_content("The survey is closed and cannot be answered.")
    end
  end

  context "when the survey allow answers" do
    before do
      feature.update_attributes!(
        step_settings: {
          feature.participatory_space.active_step.id => {
            allow_answers: true
          }
        }
      )
    end

    context "when the user is not logged in" do
      it "the survey cannot be answered" do
        visit_feature

        expect(page).to have_i18n_content(survey.title, upcase: true)
        expect(page).to have_i18n_content(survey.description)

        expect(page).to have_no_i18n_content(survey_question_1.body)
        expect(page).to have_no_i18n_content(survey_question_2.body)

        expect(page).to have_content("Sign in with your account or sign up to answer the survey.")
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "the survey can be answered" do
        visit_feature

        expect(page).to have_i18n_content(survey.title, upcase: true)
        expect(page).to have_i18n_content(survey.description)

        fill_in "survey_#{survey.id}_question_#{survey_question_1.id}_answer_body", with: "My first answer"
        fill_in "survey_#{survey.id}_question_#{survey_question_2.id}_answer_body", with: "My second answer"

        check "survey_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_content("You have already answered this survey.")
        expect(page).to have_no_i18n_content(survey_question_1.body)
        expect(page).to have_no_i18n_content(survey_question_2.body)
      end

      it "the questions are ordered by position" do
        visit_feature

        form_fields = all(".answer-survey .row")

        expect(form_fields[0]).to have_i18n_content(survey_question_2.body)
        expect(form_fields[1]).to have_i18n_content(survey_question_1.body)
      end

      context "when a question is mandatory" do
        let!(:survey_question_2) { create(:survey_question, survey: survey, position: 0, mandatory: true) }

        it "users cannot leave that question blank" do
          visit_feature

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("error")
          end
          expect(page).to have_content("can't be blank")
        end
      end

      context "when question type is long answer" do
        let!(:survey_question_1) { create(:survey_question, survey: survey, question_type: "long_answer") }
        let!(:survey_question_2) { create(:survey_question, survey: survey, question_type: "long_answer") }

        it "the question answer is rendered as a textarea" do
          visit_feature

          expect(page).to have_selector("textarea#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body")
          expect(page).to have_selector("textarea#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body")
        end
      end

      context "when question type is single option" do
        let(:answer_options) { Array.new(4) { { "body" => Decidim::Faker::Localized.sentence } } }
        let!(:survey_question_1) { create(:survey_question, survey: survey, question_type: "single_option", answer_options: [answer_options[0], answer_options[1]]) }
        let!(:survey_question_2) { create(:survey_question, survey: survey, question_type: "single_option", answer_options: [answer_options[2], answer_options[3]]) }

        it "the question answers are rendered as a collection of radio buttons" do
          visit_feature

          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options input[type='radio']", count: 2)
          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options input[type='radio']", count: 2)

          within "#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options" do
            choose answer_options[1]["body"][:en]
          end

          within "#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options" do
            choose answer_options[2]["body"][:en]
          end

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_content("You have already answered this survey.")
          expect(page).to have_no_i18n_content(survey_question_1.body)
          expect(page).to have_no_i18n_content(survey_question_2.body)
        end
      end

      context "when question type is multiple option" do
        let(:answer_options) { Array.new(4) { { "body" => Decidim::Faker::Localized.sentence } } }
        let!(:survey_question_1) { create(:survey_question, survey: survey, question_type: "multiple_option", answer_options: [answer_options[0], answer_options[1]]) }
        let!(:survey_question_2) { create(:survey_question, survey: survey, question_type: "multiple_option", answer_options: [answer_options[2], answer_options[3]]) }

        it "the question answers are rendered as a collection of radio buttons" do
          visit_feature

          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options input[type='checkbox']", count: 2)
          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options input[type='checkbox']", count: 2)

          within "#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options" do
            check answer_options[0]["body"][:en]
            check answer_options[1]["body"][:en]
          end

          within "#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options" do
            check answer_options[2]["body"][:en]
          end

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_content("You have already answered this survey.")
          expect(page).to have_no_i18n_content(survey_question_1.body)
          expect(page).to have_no_i18n_content(survey_question_2.body)
        end
      end

      context "when question type is multiple option" do
        let(:answer_options) { Array.new(4) { { "body" => Decidim::Faker::Localized.sentence } } }
        let!(:survey_question_1) { create(:survey_question, survey: survey, question_type: "multiple_option", answer_options: [answer_options[0], answer_options[1]]) }
        let!(:survey_question_2) { create(:survey_question, survey: survey, question_type: "multiple_option", answer_options: [answer_options[2], answer_options[3]]) }

        it "the question answers are rendered as a collection of radio buttons" do
          visit_feature

          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options input[type='checkbox']", count: 2)
          expect(page).to have_selector("#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options input[type='checkbox']", count: 2)

          within "#survey_#{survey.id}_question_#{survey_question_1.id}_answer_body_answer_options" do
            check answer_options[0]["body"][:en]
            check answer_options[1]["body"][:en]
          end

          within "#survey_#{survey.id}_question_#{survey_question_2.id}_answer_body_answer_options" do
            check answer_options[2]["body"][:en]
          end

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_content("You have already answered this survey.")
          expect(page).to have_no_i18n_content(survey_question_1.body)
          expect(page).to have_no_i18n_content(survey_question_2.body)
        end
      end
    end
  end
end
