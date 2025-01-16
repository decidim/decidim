# frozen_string_literal: true

require "spec_helper"

describe "Answer a survey" do
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
  let(:question_description) do
    {
      "en" => "<p>Survey's content</p>",
      "ca" => "<p>Contingut de l'enquesta</p>",
      "es" => "<p>Contenido de la encuesta</p>"
    }
  end
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:questionnaire) { create(:questionnaire, title:, description:) }
  let!(:survey) { create(:survey, :published, component:, questionnaire:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0, description: question_description) }

  include_context "with a component"

  it_behaves_like "preview component with a share_token"

  context "when the survey does not allow answers" do
    it "does not allow answering the survey" do
      visit_component

      choose "All"

      expect(page).to have_i18n_content(questionnaire.title)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_i18n_content(question.body)

      click_on translated_attribute(questionnaire.title)

      expect(page).to have_content("The form is closed and cannot be answered.")
    end
  end

  context "when the survey requires permissions to be answered" do
    before do
      permissions = {
        answer: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }

      component.update!(permissions:)
      visit_component
      choose "All"
      click_on translated_attribute(questionnaire.title)
    end

    it_behaves_like "accessible page"

    it "shows a page" do
      expect(page).to have_content("Authorization required")
    end
  end

  context "when the survey allow answers" do
    # rubocop:disable Naming/VariableNumber
    context "when survey allows editing" do
      let!(:survey) { create(:survey, :published, :allow_edit, :announcement, :allow_answers, :allow_unregistered, component:, questionnaire:) }

      before do
        visit_component
        see_questionnaire_questions

        fill_in :questionnaire_responses_0, with: "My first answer"
        check "questionnaire_tos_agreement"
        accept_confirm { click_on "Submit" }
      end

      it "restricts the change of an answer when editing is disabled" do
        expect(page).to have_content("Edit your answers")

        survey.update!(allow_editing_answers: false)

        click_on "Edit your answers"

        expect(page).to have_content("You are not allowed to edit your answers.")
      end

      it "restricts the change of an answer when form is closed" do
        expect(page).to have_content("Edit your answers")

        survey.update!(ends_at: 1.day.ago)

        click_on "Edit your answers"

        expect(page).to have_content("You are not allowed to edit your answers.")
      end

      it "allows to change the response of a text field" do
        expect(page).to have_content("Edit your answers")
        click_on "Edit your answers"

        expect(page).to have_field(:questionnaire_responses_0, with: "My first answer")

        fill_in :questionnaire_responses_0, with: "My first answer changed"
        check "questionnaire_tos_agreement"
        accept_confirm { click_on "Submit" }

        expect(page).to have_content("Edit your answers")
        click_on "Edit your answers"
        expect(page).to have_field(:questionnaire_responses_0, with: "My first answer changed")
      end
    end
    # rubocop:enable Naming/VariableNumber

    context "when the survey is closed by start and end dates" do
      before do
        survey.update!(starts_at: 1.week.ago, ends_at: 1.day.ago)
      end

      it "does not allow answering the survey" do
        visit_component
        choose "All"

        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)

        expect(page).to have_no_i18n_content(question.body)

        click_on translated_attribute(questionnaire.title)

        expect(page).to have_content("The form is closed and cannot be answered.")
      end
    end

    context "when the survey is open" do
      let(:callout_failure) { "There was a problem answering the survey." }
      let(:callout_success) { "Survey successfully answered." }

      before do
        survey.update!(allow_answers: true, starts_at: 1.week.ago, ends_at: 1.day.from_now)
      end

      it_behaves_like "has questionnaire"
    end

    context "when displaying questionnaire rich content" do
      before do
        survey.update!(
          allow_answers: true,
          allow_unregistered: true,
          starts_at: 1.week.ago,
          ends_at: 1.day.from_now
        )
        visit_component
        click_on translated_attribute(questionnaire.title)
      end

      context "when displaying questionnaire description" do
        it_behaves_like "has embedded video in description", :description
      end

      context "when displaying question description" do
        it_behaves_like "has embedded video in description", :question_description
      end
    end
  end

  context "when survey has a custom announcement" do
    let!(:survey) { create(:survey, :published, :announcement, :allow_answers, :allow_unregistered, component:, questionnaire:) }

    before do
      visit_component
      click_on translated_attribute(questionnaire.title)
    end

    it "displays the announcement in the survey" do
      expect(page).to have_content("This is a custom announcement.")
    end
  end

  context "when survey has action log entry" do
    let!(:action_log) { create(:action_log, user:, action: "publish", organization: component.organization, resource: survey, component:, participatory_space: component.participatory_space, visibility: "all") }

    let(:router) { Decidim::EngineRouter.main_proxy(component) }

    it "shows action log entry" do
      page.visit decidim.profile_activity_path(nickname: user.nickname)
      expect(page).to have_content("New survey: #{translated(survey.questionnaire.title)}")
      expect(page).to have_content(translated(survey.component.participatory_space.title))
      expect(page).to have_link(translated(survey.questionnaire.title), href: router.survey_path(survey))
    end
  end

  def questionnaire_public_path
    main_component_path(component)
  end

  def see_questionnaire_questions
    click_on translated_attribute(questionnaire.title)
  end
end
