# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings polls", type: :system do
  let(:current_organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope:, services: [], component: current_component }
  let(:poll) { create(:poll) }
  let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  describe "listing meetings" do
    it "shows manage poll action" do
      visit current_path
      within find("tr", text: translated(meeting.title)) do
        page.click_link "Manage poll"
      end

      expect(page).to have_content("Edit poll questionnaire for #{Decidim::Meetings::MeetingPresenter.new(meeting).title}")
    end
  end

  include_context "when managing a component as an admin"

  context "when the questionnaire is not already answered" do
    before do
      visit questionnaire_edit_path
    end

    it "adds a question with answer options" do
      question_body = ["This is the first question", "This is the second question"]
      answer_options_body = [
        [
          "This is the Q1 first option",
          "This is the Q1 second option",
          "This is the Q1 third option"
        ],
        [
          "This is the Q2 first option",
          "This is the Q2 second option",
          "This is the Q2 third option"
        ]
      ]

      within "form.edit_questionnaire" do
        click_button "Add question"
        click_button "Add question"
        expand_all_questions

        page.all(".questionnaire-question").each_with_index do |question, idx|
          within question do
            fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
          end
        end

        page.all(".questionnaire-question").each do |question|
          within question do
            select "Single option", from: "Type"
            click_button "Add answer option"
          end
        end

        page.all(".questionnaire-question").each_with_index do |question, question_idx|
          question.all(".questionnaire-question-answer-option").each_with_index do |question_answer_option, answer_option_idx|
            within question_answer_option do
              fill_in find_nested_form_field_locator("body_en"), with: answer_options_body[question_idx][answer_option_idx]
            end
          end
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the Q1 first option']")
      expect(page).to have_selector("input[value='This is the Q1 second option']")
      expect(page).to have_selector("input[value='This is the Q1 third option']")
      expect(page).to have_selector("input[value='This is the second question']")
      expect(page).to have_selector("input[value='This is the Q2 first option']")
      expect(page).to have_selector("input[value='This is the Q2 second option']")
      expect(page).to have_selector("input[value='This is the Q2 third option']")
    end

    it "adds a sane number of options for each attribute type" do
      click_button "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Multiple option", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")
    end

    it "does not incorrectly reorder when clicking answer options" do
      click_button "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      2.times { click_button "Add answer option" }

      within ".questionnaire-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      within ".questionnaire-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      # If JS events for option reordering are incorrectly bound, clicking on
      # the field to gain focus can cause the options to get inverted... :S
      within ".questionnaire-question-answer-option:first-of-type" do
        find_nested_form_field("body_en").click
      end

      within ".questionnaire-question-answer-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".questionnaire-question-answer-option:last-of-type" do
        expect(page).to have_nested_field("body_en", with: "Else")
      end
    end

    it "preserves question form across submission failures" do
      click_button "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      click_button "Save"

      expand_all_questions
      expect(page).to have_select("Type", selected: "Single option")
    end

    it "preserves answer options form across submission failures" do
      click_button "Add question"
      expand_all_questions

      select "Multiple option", from: "Type"

      within ".questionnaire-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      click_button "Add answer option"

      within ".questionnaire-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      select "3", from: "Maximum number of choices"

      click_button "Save"
      expand_all_questions

      within ".questionnaire-question-answer-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".questionnaire-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      expect(page).to have_select("Maximum number of choices", selected: "3")
    end

    context "when adding a multiple option question" do
      before do
        visit questionnaire_edit_path

        within "form.edit_questionnaire" do
          click_button "Add question"

          expand_all_questions

          within ".questionnaire-question" do
            fill_in find_nested_form_field_locator("body_en"), with: "This is the first question"
          end

          expect(page).to have_no_select("Maximum number of choices")
        end
      end

      it "updates the free text option selector according to the selected question type" do
        expect(page).to have_no_selector("[id$=max_choices]")

        select "Multiple option", from: "Type"
        expect(page).to have_selector("[id$=max_choices]")

        select "Single option", from: "Type"
        expect(page).to have_no_selector("[id$=max_choices]")
      end

      it "updates the max choices selector according to the configured options" do
        expect(page).to have_no_select("Maximum number of choices")

        select "Multiple option", from: "Type"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        click_button "Add answer option"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3))

        click_button "Add answer option"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3 4))

        within(".questionnaire-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3))

        within(".questionnaire-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        click_button "Add question"
        expand_all_questions

        within(".questionnaire-question:last-of-type") do
          select "Multiple option", from: "Type"
          expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

          select "Single option", from: "Type"
          expect(page).to have_no_select("Maximum number of choices")
        end
      end
    end
  end

  context "when the questionnaire is already answered" do
    let!(:question) { create(:meetings_poll_question, questionnaire:, body:, question_type: "multiple_option") }
    let!(:answer) { create(:meetings_poll_answer, questionnaire:, question:) }

    it "can modify questionnaire questions" do
      visit questionnaire_edit_path

      expect(page).to have_content("Add question")
      expect(page).to have_no_content("Remove")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: :visible)
    find_nested_form_field(attribute, visible:)["id"]
  end

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:, match: :first)
  end

  def have_nested_field(attribute, with:)
    have_field find_nested_form_field_locator(attribute), with:
  end

  def have_no_nested_field(attribute, with:)
    have_no_field(find_nested_form_field_locator(attribute), with:)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def expand_all_questions
    find(".button.expand-all").click
  end

  def visit_questionnaire_edit_path_and_expand_all
    visit questionnaire_edit_path
    expand_all_questions
  end

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_poll_path(meeting_id: meeting.id)
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(component).meeting_path(meeting_id: meeting.id)
  end
end
