# frozen_string_literal: true

require "spec_helper"

describe "Answer a survey", type: :system do
  InvisibleCaptcha.honeypots = [:honeypot_id]
  InvisibleCaptcha.visual_honeypots = true

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
  let!(:questionnaire) { create(:questionnaire, title:, description:) }
  let!(:survey) { create(:survey, component:, questionnaire:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }

  include_context "with a component"

  context "when the survey doesn't allow answers" do
    it "does not allow answering the survey" do
      visit_component

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_i18n_content(question.body)

      expect(page).to have_content("The form is closed and cannot be answered.")
    end
  end

  context "when the survey allow answers" do
    let(:last_answer) { questionnaire.answers.last }

    before do
      component.update!(
        step_settings: {
          component.participatory_space.active_step.id => {
            allow_answers: true,
            allow_unregistered: true
          }
        }
      )
    end

    it "allows answering the questionnaire" do
      visit_component

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      accept_confirm { click_button "Submit" }

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      # Unregistered users are tracked with their session_id so they won't be allowed to repeat easily
      expect(page).to have_content("You have already answered this form.")
      expect(page).to have_no_i18n_content(question.body)

      expect(last_answer.session_token).not_to be_empty
      expect(last_answer.ip_hash).not_to be_empty
    end

    context "and honeypot is filled" do
      it "fails with spam complain" do
        visit_component
        fill_in question.body["en"], with: "My first answer"
        fill_in "honeypot_id", with: "I am a robot"

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".alert.flash", wait: 5 do
          expect(page).to have_content("problem")
        end
      end
    end

    def questionnaire_public_path
      main_component_path(component)
    end
  end
end
