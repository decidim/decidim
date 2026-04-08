# frozen_string_literal: true

require "spec_helper"

describe "Transparent Space Respond a survey" do
  let(:manifest_name) { "surveys" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }

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

  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:another_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: another_user, participatory_space:) }

  let!(:questionnaire) { create(:questionnaire, title:, description:) }
  let!(:survey) { create(:survey, :published, :allow_responses, component:, questionnaire:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let!(:question_conditioned) { create(:questionnaire_question, :conditioned, questionnaire:, position: 1) }

  let!(:participatory_space) { create(:assembly, :published, :transparent, organization:) }
  let!(:component) { create(:component, manifest:, participatory_space:) }

  def visit_component
    page.visit main_component_path(component)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the user is not logged in" do
    it "does not allow responding the survey" do
      visit_component
      click_on translated_attribute(questionnaire.title)

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_css(".form.response-questionnaire")

      within ".response-questionnaire__step" do
        expect(page).to have_i18n_content(question.body)
        expect(page).not_to have_i18n_content(question_conditioned.body)
      end
    end
  end

  context "when the user is logged in" do
    context "and is member space" do
      before do
        login_as another_user, scope: :user
      end

      it "allows responding the survey" do
        visit_component
        click_on translated_attribute(questionnaire.title)

        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)

        fill_in question.body["en"], with: "My first response"

        check "questionnaire_tos_agreement"

        accept_confirm { click_on "Submit" }

        expect(page).to have_callout("Survey successfully responded.")
        expect(page).to have_content("You have already responded this form.")
        expect(page).to have_no_i18n_content(question.body)
      end
    end

    context "and is not member space" do
      before do
        login_as user, scope: :user
      end

      it "not allows responding the survey" do
        visit_component
        click_on translated_attribute(questionnaire.title)

        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)
        expect(page).to have_content "The form is available only for members"
        expect(page).to have_content "Form closed"

        expect(page).to have_css(".button[disabled]")
      end
    end
  end
end
