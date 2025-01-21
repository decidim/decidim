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

    context "when the survey has questions' answers published" do
      let(:question_single_option) { create(:questionnaire_question, :with_answer_options, question_type: "single_option", questionnaire:) }

      let(:question_multiple_option) { create(:questionnaire_question, :with_answer_options, question_type: "multiple_option", questionnaire:) }

      let(:question_matrix_single) { create(:questionnaire_question, :with_answer_options, question_type: "matrix_single", questionnaire:) }
      let!(:question_matrix_row_single1) { create(:question_matrix_row, question: question_matrix_single) }
      let!(:question_matrix_row_single2) { create(:question_matrix_row, question: question_matrix_single) }
      let!(:question_matrix_row_single3) { create(:question_matrix_row, question: question_matrix_single) }

      let(:question_matrix_multiple) { create(:questionnaire_question, :with_answer_options, question_type: "matrix_multiple", questionnaire:) }
      let!(:question_matrix_row_multiple1) { create(:question_matrix_row, question: question_matrix_multiple) }
      let!(:question_matrix_row_multiple2) { create(:question_matrix_row, question: question_matrix_multiple) }
      let!(:question_matrix_row_multiple3) { create(:question_matrix_row, question: question_matrix_multiple) }

      let(:question_sorting) { create(:questionnaire_question, :with_answer_options, question_type: "sorting", questionnaire:) }

      before do
        10.times do
          answer = create(:answer, question: question_single_option, questionnaire:)
          answer_option = question_single_option.answer_options.sample
          create(:answer_choice, answer_option:, answer:, matrix_row: nil)

          answer = create(:answer, question: question_multiple_option, questionnaire:)
          answer_option = question_multiple_option.answer_options.sample
          create(:answer_choice, answer_option:, answer:, matrix_row: nil)

          answer = create(:answer, question: question_matrix_single, questionnaire:)
          answer_option = question_matrix_single.answer_options.sample
          matrix_row = question_matrix_single.matrix_rows.sample
          create(:answer_choice, answer_option:, answer:, matrix_row:)

          answer = create(:answer, question: question_matrix_multiple, questionnaire:)
          answer_option = question_matrix_multiple.answer_options.sample
          matrix_row = question_matrix_multiple.matrix_rows.sample
          create(:answer_choice, answer_option:, answer:, matrix_row:)

          answer = create(:answer, question: question_sorting, questionnaire:)
          answer_option = question_sorting.answer_options.sample
          position = (0..(question_sorting.answer_options.count - 1)).to_a.sample
          create(:answer_choice, answer_option:, answer:, position:, matrix_row: nil)
        end
      end

      it "shows the charts when questions answers are published" do
        visit_component
        choose "All"
        click_on translated_attribute(questionnaire.title)

        # does not show the charts if not published
        expect(page.html).not_to include('new Chartkick["ColumnChart"]("chart-1"')
        expect(page.html).not_to include('new Chartkick["ColumnChart"]("chart-2"')
        expect(page.html).not_to include('new Chartkick["ColumnChart"]("chart-3"')
        expect(page.html).not_to include('new Chartkick["ColumnChart"]("chart-4"')
        expect(page.html).not_to include('new Chartkick["BarChart"]("chart-5"')

        [question_single_option, question_multiple_option, question_matrix_single, question_matrix_multiple, question_sorting].each do |question|
          question.update!(survey_answers_published_at: Time.current)
        end

        visit current_path

        # shows the charts
        expect(page.html).to include('new Chartkick["ColumnChart"]("chart-1"')
        expect(page.html).to include('new Chartkick["ColumnChart"]("chart-2"')
        expect(page.html).to include('new Chartkick["ColumnChart"]("chart-3"')
        expect(page.html).to include('new Chartkick["ColumnChart"]("chart-4"')
        expect(page.html).to include('new Chartkick["BarChart"]("chart-5"')
      end
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
