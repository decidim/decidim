# frozen_string_literal: true

require "spec_helper"

shared_examples_for "add questions" do
  shared_examples_for "updating the max choices selector according to the configured options" do
    it "updates them" do
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
        select multiple_option_string, from: "Type"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        select single_option_string, from: "Type"
        expect(page).to have_no_select("Maximum number of choices")
      end
    end
  end

  it "adds a few questions and separators to the questionnaire" do
    fields_body = ["This is the first question", "This is the second question", "This is the first title and description"]
    click_on "Add question"
    click_on "Add separator"
    click_on "Add title and description"
    click_on "Add question"

    expect(page).to have_css(".questionnaire-question", count: 4)

    expand_all_questions

    page.all(".questionnaire-question .collapsible").each_with_index do |field, idx|
      within field do
        fill_in find_nested_form_field_locator("body_en"), with: fields_body[idx]
      end
    end

    click_on "Save"

    expect(page).to have_admin_callout("successfully")

    visit_manage_questions_and_expand_all

    expect(page).to have_css("input[value='This is the first question']")
    expect(page).to have_css("input[value='This is the second question']")
    expect(page).to have_css("input[value='This is the first title and description']")
    expect(page).to have_content("Separator #2")
  end

  it "adds a question with a rich text description" do
    click_on "Add question"
    expand_all_questions

    within ".questionnaire-question" do
      fill_in find_nested_form_field_locator("body_en"), with: "Body"

      fill_in_editor find_nested_form_field_locator("description_en", visible: false), with: "<p>\n<strong>Superkalifragilistic description</strong>\n</p>"
    end

    click_on "Save"

    expect(page).to have_admin_callout("successfully")

    update_component_settings_or_attributes

    visit questionnaire_public_path
    see_questionnaire_questions

    expect(page).to have_css("strong", text: "Superkalifragilistic description")
  end

  it "adds a title-and-description" do
    click_on "Add title and description"
    expand_all_questions

    within ".questionnaire-question" do
      fill_in find_nested_form_field_locator("body_en"), with: "Body"

      fill_in_editor find_nested_form_field_locator("description_en", visible: false), with: "<p>\n<strong>Superkalifragilistic description</strong>\n</p>"
    end

    click_on "Save"

    expect(page).to have_admin_callout("successfully")

    update_component_settings_or_attributes

    visit questionnaire_public_path
    see_questionnaire_questions

    expect(page).to have_css("strong", text: "Superkalifragilistic description")
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

    click_on "Add question"
    click_on "Add question"
    expand_all_questions

    page.all(".questionnaire-question").each_with_index do |question, idx|
      within question do
        fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
      end
    end

    expect(page).to have_no_content "Add response option"

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

    expect(page).to have_admin_callout("successfully")

    visit_manage_questions_and_expand_all

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

    select "Long response", from: "Type"
    expect(page).to have_no_css(".questionnaire-question-response-option")
    expect(page).to have_no_css(".questionnaire-question-matrix-row")

    select "Single option", from: "Type"
    expect(page).to have_css(".questionnaire-question-response-option", count: 2)
    expect(page).to have_no_css(".questionnaire-question-matrix-row")

    select "Multiple option", from: "Type"
    expect(page).to have_css(".questionnaire-question-response-option", count: 2)
    expect(page).to have_no_css(".questionnaire-question-matrix-row")

    select "Matrix (Multiple option)", from: "Type"
    expect(page).to have_css(".questionnaire-question-response-option", count: 2)
    expect(page).to have_css(".questionnaire-question-matrix-row", count: 2)

    select "Short response", from: "Type"
    expect(page).to have_no_css(".questionnaire-question-response-option")
    expect(page).to have_no_css(".questionnaire-question-matrix-row")

    select "Matrix (Single option)", from: "Type"
    expect(page).to have_css(".questionnaire-question-response-option", count: 2)
    expect(page).to have_css(".questionnaire-question-matrix-row", count: 2)
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

  it "does not incorrectly reorder when clicking matrix rows" do
    click_on "Add question"
    expand_all_questions

    select "Matrix (Multiple option)", from: "Type"
    2.times { click_on "Add row" }

    within ".questionnaire-question-matrix-row:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Something"
    end

    within ".questionnaire-question-matrix-row:last-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Else"
    end

    # If JS events for option reordering are incorrectly bound, clicking on
    # the field to gain focus can cause the options to get inverted... :S
    within ".questionnaire-question-matrix-row:first-of-type" do
      find_nested_form_field("body_en").click
    end

    within ".questionnaire-question-matrix-row:first-of-type" do
      expect(page).to have_nested_field("body_en", with: "Something")
    end

    within ".questionnaire-question-matrix-row:last-of-type" do
      expect(page).to have_nested_field("body_en", with: "Else")
    end
  end

  it "preserves question form across submission failures" do
    click_on "Add question"
    expand_all_questions

    expect(page).to have_text("Type")
    select "Long response", from: "Type"
    click_on "Save"

    expand_all_questions
    expect(page).to have_select("Type", selected: "Long response", wait: 10)
  end

  it "does not preserve spurious response options from previous type selections" do
    click_on "Add question"
    expand_all_questions

    select "Single option", from: "Type"

    within ".questionnaire-question-response-option:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Something"
    end

    select "Long response", from: "Type"

    click_on "Save"
    expand_all_questions

    expect(page).to have_text("Type")
    select "Single option", from: "Type"

    within ".questionnaire-question-response-option:first-of-type" do
      expect(page).to have_no_nested_field("body_en", with: "Something")
    end
  end

  it "does not preserve spurious matrix rows from previous type selections" do
    click_on "Add question"
    expand_all_questions

    select "Matrix (Single option)", from: "Type"

    within ".questionnaire-question-matrix-row:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Something"
    end

    select "Long response", from: "Type"

    click_on "Save"
    expand_all_questions

    expect(page).to have_text("Type")
    select "Matrix (Single option)", from: "Type"

    within ".questionnaire-question-matrix-row:first-of-type" do
      expect(page).to have_no_nested_field("body_en", with: "Something")
    end
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

    expect(page).to have_css(".questionnaire-question-response-option")
    within ".questionnaire-question-response-option:first-of-type" do
      expect(page).to have_nested_field("body_en", with: "Something")
    end

    within ".questionnaire-question-response-option:last-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Else"
    end

    expect(page).to have_select("Maximum number of choices", selected: "3")
  end

  it "preserves matrix rows form across submission failures" do
    click_on "Add question"
    expand_all_questions

    select "Matrix (Multiple option)", from: "Type"

    within ".questionnaire-question-matrix-row:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Something"
    end

    click_on "Add row"

    click_on "Save"
    expand_all_questions

    within ".questionnaire-question-matrix-row:first-of-type" do
      expect(page).to have_nested_field("body_en", with: "Something")
    end
  end

  it "allows switching translated field tabs after form failures" do
    click_on "Add question"

    expand_all_questions

    within ".questionnaire-question:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Bye"
      click_on "Català", match: :first

      fill_in find_nested_form_field_locator("body_ca"), with: "Adeu"
      click_on "English", match: :first

      expect(page).to have_nested_field("body_en", with: "Bye")
      expect(page).to have_no_selector(nested_form_field_selector("body_ca"))
      expect(page).to have_no_content("Adeu")
    end
  end

  context "when adding a multiple option question" do
    let(:multiple_option_string) { "Multiple option" }
    let(:single_option_string) { "Single option" }

    before do
      click_on "Add question"

      expand_all_questions

      within ".questionnaire-question" do
        fill_in find_nested_form_field_locator("body_en"), with: "This is the first question"
      end

      expect(page).to have_no_content "Add response option"
      expect(page).to have_no_select("Maximum number of choices")
    end

    it "updates the free text option selector according to the selected question type" do
      expect(page).to have_no_css("input[type=checkbox][id$=_free_text]")

      select "Multiple option", from: "Type"
      expect(page).to have_css("input[type=checkbox][id$=_free_text]")

      select "Short response", from: "Type"
      expect(page).to have_no_css("input[type=checkbox][id$=_free_text]")

      select "Single option", from: "Type"
      expect(page).to have_css("input[type=checkbox][id$=_free_text]")
    end

    it_behaves_like "updating the max choices selector according to the configured options"
  end

  context "when adding a matrix question" do
    let(:multiple_option_string) { "Matrix (Multiple option)" }
    let(:single_option_string) { "Matrix (Single option)" }

    before do
      click_on "Add question"
      expand_all_questions

      within ".questionnaire-question" do
        fill_in find_nested_form_field_locator("body_en"), with: "This is the first question"
      end

      expect(page).to have_no_content "Add response option"
      expect(page).to have_no_content "Add row"
      expect(page).to have_no_select("Maximum number of choices")
    end

    it "updates the free text option selector according to the selected question type" do
      expect(page).to have_no_css("input[type=checkbox][id$=_free_text]")

      select "Matrix (Multiple option)", from: "Type"
      expect(page).to have_css("input[type=checkbox][id$=_free_text]")

      select "Short response", from: "Type"
      expect(page).to have_no_css("input[type=checkbox][id$=_free_text]")

      select "Matrix (Single option)", from: "Type"
      expect(page).to have_css("input[type=checkbox][id$=_free_text]")
    end

    it_behaves_like "updating the max choices selector according to the configured options"
  end
end
