# frozen_string_literal: true

require "spec_helper"

describe "Respond a survey" do
  before do
    allow(InvisibleCaptcha).to receive(:honeypots).and_return([:honeypot_id])
    allow(InvisibleCaptcha).to receive(:visual_honeypots).and_return(true)
  end

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
  let!(:survey) { create(:survey, :published, component:, questionnaire:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }

  include_context "with a component"

  context "when the survey does not allow responses" do
    it "does not allow responding the survey" do
      visit_component
      choose "All"
      click_on translated_attribute(questionnaire.title)

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_i18n_content(question.body)

      expect(page).to have_content("The form is closed and cannot be responded.")
    end
  end

  context "when the survey allow responses" do
    let(:last_response) { questionnaire.responses.last }

    before do
      survey.update!(allow_responses: true, allow_unregistered: true)
    end

    # rubocop:disable Naming/VariableNumber
    context "when survey allows editing" do
      let(:question_description) do
        {
          "en" => "<p>Survey's content</p>",
          "ca" => "<p>Contingut de l'enquesta</p>",
          "es" => "<p>Contenido de la encuesta</p>"
        }
      end
      let(:options) do
        [
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence },
          { "body" => Decidim::Faker::Localized.sentence }
        ]
      end
      let(:max_characters) { 0 }
      let(:max_choices) { nil }

      let!(:survey) { create(:survey, :published, :allow_edit, :announcement, :allow_responses, :allow_unregistered, component:, questionnaire:) }
      let!(:second_question) { create(:questionnaire_question, position: 1, questionnaire:, question_type: :multiple_option, max_choices:, max_characters:, options:) }
      let!(:question) { create(:questionnaire_question, questionnaire:, mandatory: true, position: 0, description: question_description) }

      before do
        visit_component
        click_on translated_attribute(questionnaire.title)

        fill_in :questionnaire_responses_0, with: "My first response"
        check "questionnaire_tos_agreement"
        accept_confirm { click_on "Submit" }
      end

      it "restricts the change of an response when editing is disabled" do
        expect(page).to have_content("Already responded")
      end

      it "hides the form when on edit page" do
        visit Decidim::EngineRouter.main_proxy(survey.component).edit_survey_path(survey)
        expect(page).to have_content("Already responded")
      end
    end
    # rubocop:enable Naming/VariableNumber

    it "allows responding the questionnaire" do
      visit_component
      click_on translated_attribute(questionnaire.title)

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first response"

      check "questionnaire_tos_agreement"

      accept_confirm { click_on "Submit" }

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      # Unregistered users are tracked with their session_id so they will not be allowed to repeat easily
      expect(page).to have_content("You have already responded this form.")
      expect(page).to have_no_i18n_content(question.body)

      expect(last_response.session_token).not_to be_empty
      expect(last_response.ip_hash).not_to be_empty
    end

    context "and honeypot is filled" do
      it "fails with spam complain" do
        visit_component
        click_on translated_attribute(questionnaire.title)
        fill_in question.body["en"], with: "My first response"
        fill_in "honeypot_id", with: "I am a robot"

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

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
