# frozen_string_literal: true

require "spec_helper"

describe "Answer a survey" do
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
  let!(:survey) { create(:survey, :published, component:, questionnaire:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let(:mailer) { double(deliver_later: true) }

  include_context "with a component"

  context "when the survey does not allow answers" do
    it "does not allow answering the survey" do
      visit_component
      choose "All"
      click_on translated_attribute(questionnaire.title)

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_i18n_content(question.body)

      expect(page).to have_content("The form is closed and cannot be answered.")
    end
  end

  context "when the survey allow answers" do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:survey) { create(:survey, :published, :allow_answers, allow_unregistered: false, component:, questionnaire:) }

    before do
      login_as user, scope: :user
    end

    it "allows answering the questionnaire" do
      allow(Decidim::Surveys::SurveyConfirmationMailer).to receive(:confirmation).and_return(mailer)

      visit_component
      click_on translated_attribute(questionnaire.title)

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      accept_confirm { click_on "Submit" }

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("You have already answered this form.")
      expect(page).to have_no_i18n_content(question.body)

      expect(questionnaire.answers.last.session_token).not_to be_empty
      expect(questionnaire.answers.last.ip_hash).not_to be_empty

      expect(Decidim::Surveys::SurveyConfirmationMailer).to have_received(:confirmation).with(user, questionnaire, [[questionnaire.answers.last]])
      expect(mailer).to have_received(:deliver_later)
    end

    def questionnaire_public_path
      main_component_path(component)
    end
  end
end
