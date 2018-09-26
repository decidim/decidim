# frozen_string_literal: true

require "spec_helper"

describe "Private Space Answer a survey", type: :system do
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
  let(:user) { create :user, :confirmed, organization: organization }
  let!(:other_user) { create(:user, :confirmed, organization: organization) }

  let!(:participatory_space_private_user) { create :participatory_space_private_user, user: other_user, privatable_to: participatory_space_private }

  let!(:survey) { create(:survey, component: component, title: title, description: description) }
  let!(:survey_question) { create(:survey_question, survey: survey, position: 0) }

  let!(:participatory_space) { participatory_space_private }

  let!(:component) { create(:component, manifest: manifest, participatory_space: participatory_space) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { allow_answers: true })
  end

  def visit_component
    page.visit main_component_path(component)
  end

  context "when space is private and transparent" do
    let!(:participatory_space_private) { create :assembly, :published, organization: organization, private_space: true, is_transparent: true }

    context "when the user is not logged in" do
      it "does not allow answering the survey" do
        visit_component

        within ".wrapper" do
          expect(page).to have_i18n_content(survey.title, upcase: true)
          expect(page).to have_i18n_content(survey.description)

          expect(page).to have_no_i18n_content(survey_question.body)

          expect(page).to have_content("Sign in with your account or sign up to answer the survey.")
        end
      end
    end

    context "when the user is logged in" do
      context "and is private user space" do
        before do
          login_as other_user, scope: :user
        end

        it "allows answering the survey" do
          visit_component

          expect(page).to have_i18n_content(survey.title, upcase: true)
          expect(page).to have_i18n_content(survey.description)

          fill_in survey_question.body["en"], with: "My first answer"

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_content("You have already answered this survey.")
          expect(page).to have_no_i18n_content(survey_question.body)
        end
      end

      context "and is not private user space" do
        before do
          login_as user, scope: :user
        end

        it "not allows answering the survey" do
          visit_component

          within ".wrapper" do
            expect(page).to have_i18n_content(survey.title, upcase: true)
            expect(page).to have_i18n_content(survey.description)
            expect(page).to have_content "The survey is available only for private users"
            expect(page).to have_content "Survey closed"

            expect(page).to have_selector(".button[disabled]")
          end
        end
      end
    end
  end

  context "when the spaces is private and not transparent" do
    let!(:participatory_space_private) { create :assembly, :published, organization: organization, private_space: true, is_transparent: false }

    context "when the user is not logged in" do
      it_behaves_like "a 404 page" do
        let(:target_path) { main_component_path(component) }
      end
    end

    context "when the user is logged in" do
      context "and is private user space" do
        before do
          login_as other_user, scope: :user
        end

        it "allows answering the survey" do
          visit_component

          expect(page).to have_i18n_content(survey.title, upcase: true)
          expect(page).to have_i18n_content(survey.description)

          fill_in survey_question.body["en"], with: "My first answer"

          check "survey_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_content("You have already answered this survey.")
          expect(page).to have_no_i18n_content(survey_question.body)
        end
      end

      context "and is not private user space" do
        before do
          login_as user, scope: :user
        end

        it_behaves_like "a 404 page" do
          let(:target_path) { main_component_path(component) }
        end
      end
    end
  end
end
