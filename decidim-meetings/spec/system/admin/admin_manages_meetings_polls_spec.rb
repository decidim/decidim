# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings polls" do
  let(:current_organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "meetings") }
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, scope:, services: [], component: current_component) }
  let(:poll) { create(:poll, meeting:) }
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
      within "tr", text: translated(meeting.title) do
        find("button[data-component='dropdown']").click
        click_on "Manage poll"
      end

      expect(page).to have_content("Edit poll questionnaire for #{Decidim::Meetings::MeetingPresenter.new(meeting).title}")
    end
  end

  include_context "when managing a component as an admin"

  context "when the questionnaire has unpublished questions" do
    before do
      visit questionnaire_edit_path
    end

    it "adds a question with response options" do
      question_body = ["This is the first question", "This is the second question"]
      response_options_body = [
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
        click_on "Add question"
        click_on "Add question"
        expand_all_questions

        page.all(".questionnaire-question").each_with_index do |question, idx|
          within question do
            fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
          end
        end

        page.all(".questionnaire-question").each do |question|
          within question do
            select "Single option", from: "Type"
            click_on "Add response option"
          end
        end

        page.all(".questionnaire-question").each_with_index do |question, question_idx|
          question.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
            within question_response_option do
              fill_in find_nested_form_field_locator("body_en"), with: response_options_body[question_idx][response_option_idx]
            end
          end
        end

        click_on "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_css("input[value='This is the first question']")
      expect(page).to have_css("input[value='This is the Q1 first option']")
      expect(page).to have_css("input[value='This is the Q1 second option']")
      expect(page).to have_css("input[value='This is the Q1 third option']")
      expect(page).to have_css("input[value='This is the second question']")
      expect(page).to have_css("input[value='This is the Q2 first option']")
      expect(page).to have_css("input[value='This is the Q2 second option']")
      expect(page).to have_css("input[value='This is the Q2 third option']")
    end

    it "adds a sane number of options for each attribute type" do
      click_on "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      expect(page).to have_css(".questionnaire-question-response-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Multiple option", from: "Type"
      expect(page).to have_css(".questionnaire-question-response-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")
    end

    it "does not incorrectly reorder when clicking response options" do
      click_on "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      2.times { click_on "Add response option" }

      within ".questionnaire-question-response-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      within ".questionnaire-question-response-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      # If JS events for option reordering are incorrectly bound, clicking on
      # the field to gain focus can cause the options to get inverted... :S
      within ".questionnaire-question-response-option:first-of-type" do
        find_nested_form_field("body_en").click
      end

      within ".questionnaire-question-response-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".questionnaire-question-response-option:last-of-type" do
        expect(page).to have_nested_field("body_en", with: "Else")
      end
    end

    it "preserves question form across submission failures" do
      click_on "Add question"
      expand_all_questions

      select "Single option", from: "Type"
      click_on "Save"

      expand_all_questions
      expect(page).to have_select("Type", selected: "Single option")
    end

    it "preserves response options form across submission failures" do
      click_on "Add question"
      expand_all_questions

      select "Multiple option", from: "Type"

      within ".questionnaire-question-response-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      click_on "Add response option"

      within ".questionnaire-question-response-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      select "3", from: "Maximum number of choices"

      click_on "Save"
      expand_all_questions

      within ".questionnaire-question-response-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".questionnaire-question-response-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      expect(page).to have_select("Maximum number of choices", selected: "3")
    end

    context "when adding a multiple option question" do
      before do
        visit questionnaire_edit_path

        within "form.edit_questionnaire" do
          click_on "Add question"

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
        expect(page).to have_css("[id$=max_choices]")

        select "Single option", from: "Type"
        expect(page).to have_no_selector("[id$=max_choices]")
      end

      it "updates the max choices selector according to the configured options" do
        expect(page).to have_no_select("Maximum number of choices")

        select "Multiple option", from: "Type"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        click_on "Add response option"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3))

        click_on "Add response option"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3 4))

        within(".questionnaire-question-response-option:last-of-type") { click_on "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3))

        within(".questionnaire-question-response-option:last-of-type") { click_on "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        click_on "Add question"
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

  context "when the questionnaire includes published and closed questions" do
    let!(:unpublished_question) { create(:meetings_poll_question, :unpublished, questionnaire:, question_type: "single_option", position: 0) }
    let!(:published_question) { create(:meetings_poll_question, :published, questionnaire:, question_type: "single_option", position: 1) }
    let!(:closed_question) { create(:meetings_poll_question, :closed, questionnaire:, question_type: "single_option", position: 2) }

    it "displays all questions with inputs disabled for not unpublished questions" do
      visit questionnaire_edit_path

      expand_all_questions

      expect(page).to have_css("input[value='#{translated_attribute(unpublished_question.body)}']:not([disabled])")
      expect(page).to have_css("input[value='#{translated_attribute(published_question.body)}'][disabled='disabled']")
      expect(page).to have_css("input[value='#{translated_attribute(closed_question.body)}'][disabled='disabled']")
    end

    it "can create new questions" do
      visit questionnaire_edit_path

      click_on "Add question"

      expand_all_questions

      within ".questionnaire-question:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "New question title"
        page.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
          within question_response_option do
            fill_in find_nested_form_field_locator("body_en"), with: "New question response option #{response_option_idx + 1}"
          end
        end
      end
      click_on "Save"

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_css("input[value='New question title']")
      expect(page).to have_css("input[value='New question response option 1']")
      expect(page).to have_css("input[value='New question response option 2']")
    end

    it "can modify questionnaire open questions" do
      visit questionnaire_edit_path

      expect(page).to have_content("Add question")
      expand_all_questions
      within "#questionnaire_question_#{unpublished_question.id}-field" do
        expect(page).to have_content("Remove")
        expect(page).to have_content("Add response option")
        fill_in find_nested_form_field_locator("body_en"), with: "Changed title"
        page.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
          within question_response_option do
            fill_in find_nested_form_field_locator("body_en"), with: "Changed response option #{response_option_idx + 1}"
          end
        end
      end

      click_on "Save"

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_css("input[value='Changed title']")
      expect(page).to have_css("input[value='Changed response option 1']")
      expect(page).to have_css("input[value='Changed response option 2']")
      expect(page).to have_css("input[value='Changed response option 3']")
    end

    context "when there are validation errors" do
      before do
        visit questionnaire_edit_path
        click_on "Add question"
        click_on "Save"
      end

      it "keeps the content of blocked questions" do
        expect(page).to have_content("There was a problem updating this meeting poll")
        expand_all_questions

        expect(page).to have_css("input[value='#{translated_attribute(unpublished_question.body)}']:not([disabled])")
        expect(page).to have_css("input[value='#{translated_attribute(published_question.body)}'][disabled='disabled']")
        expect(page).to have_css("input[value='#{translated_attribute(closed_question.body)}'][disabled='disabled']")
      end
    end

    it "can reorder published or closed questions" do
      visit questionnaire_edit_path
      within "#questionnaire_question_#{unpublished_question.id}-field" do
        expect(page).to have_content("Remove")
        expect(page).to have_content("Down")
        expect(page).to have_no_content("Up")
      end

      within "#questionnaire_question_#{published_question.id}-field" do
        expect(page).to have_no_content("Remove")
        expect(page).to have_content("Down")
        expect(page).to have_content("Up")
      end

      within "#questionnaire_question_#{closed_question.id}-field" do
        expect(page).to have_no_content("Remove")
        expect(page).to have_no_content("Down")
        expect(page).to have_content("Up")
      end

      within "#questionnaire_question_#{closed_question.id}-field" do
        click_on "Up"
        click_on "Up"
      end

      within "#questionnaire_question_#{unpublished_question.id}-field" do
        click_on "Down"
      end

      click_on "Save"

      expand_all_questions

      within ".questionnaire-question:last-of-type" do
        expect(page).to have_css("#questionnaire_question_#{unpublished_question.id}-button")
      end
      within ".questionnaire-question:first-of-type" do
        expect(page).to have_css("#questionnaire_question_#{closed_question.id}-button")
      end
      expect(unpublished_question.reload.position).to eq(2)
      expect(published_question.reload.position).to eq(1)
      expect(closed_question.reload.position).to eq(0)
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
    click_on "Expand all questions"
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
