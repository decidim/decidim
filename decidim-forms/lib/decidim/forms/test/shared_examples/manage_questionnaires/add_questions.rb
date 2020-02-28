# frozen_string_literal: true

require "spec_helper"

shared_examples_for "add questions" do
  it "adds a few questions to the questionnaire" do
    questions_body = ["This is the first question", "This is the second question"]

    within "form.edit_questionnaire" do
      2.times { click_button "Add question" }

      expect(page).to have_selector(".questionnaire-question", count: 2)

      page.all(".questionnaire-question").each_with_index do |question, idx|
        within question do
          fill_in find_nested_form_field_locator("body_en"), with: questions_body[idx]
        end
      end

      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit questionnaire_edit_path

    expect(page).to have_selector("input[value='This is the first question']")
    expect(page).to have_selector("input[value='This is the second question']")
  end

  it "adds a question with a rich text description" do
    within "form.edit_questionnaire" do
      click_button "Add question"

      within ".questionnaire-question" do
        fill_in find_nested_form_field_locator("body_en"), with: "Body"

        fill_in_editor find_nested_form_field_locator("description_en", visible: false), with: "<b>Superkalifragilistic description</b>"
      end

      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => {
          allow_answers: true
        }
      }
    )

    visit questionnaire_public_path

    expect(page).to have_selector("strong", text: "Superkalifragilistic description")
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

      page.all(".questionnaire-question").each_with_index do |question, idx|
        within question do
          fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
        end
      end

      expect(page).to have_no_content "Add answer option"

      page.all(".questionnaire-question").each do |question|
        within question do
          select "Single option", from: "Type"
          click_button "Add answer option"
        end
      end

      page.all(".questionnaire-question").each_with_index do |question, idx|
        question.all(".questionnaire-question-answer-option").each_with_index do |question_answer_option, aidx|
          within question_answer_option do
            fill_in find_nested_form_field_locator("body_en"), with: answer_options_body[idx][aidx]
          end
        end
      end

      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit questionnaire_edit_path

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

    select "Long answer", from: "Type"
    expect(page).to have_no_selector(".questionnaire-question-answer-option")

    select "Single option", from: "Type"
    expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

    select "Multiple option", from: "Type"
    expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

    select "Single option", from: "Type"
    expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

    select "Short answer", from: "Type"
    expect(page).to have_no_selector(".questionnaire-question-answer-option")
  end

  it "does not incorrectly reorder when clicking answer options" do
    click_button "Add question"
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
    select "Long answer", from: "Type"
    click_button "Save"

    expect(page).to have_select("Type", selected: "Long answer")
  end

  it "does not preserve spurious answer options from previous type selections" do
    click_button "Add question"
    select "Single option", from: "Type"

    within ".questionnaire-question-answer-option:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Something"
    end

    select "Long answer", from: "Type"

    click_button "Save"

    select "Single option", from: "Type"

    within ".questionnaire-question-answer-option:first-of-type" do
      expect(page).to have_no_nested_field("body_en", with: "Something")
    end
  end

  it "preserves answer options form across submission failures" do
    click_button "Add question"
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

    within ".questionnaire-question-answer-option:first-of-type" do
      expect(page).to have_nested_field("body_en", with: "Something")
    end

    within ".questionnaire-question-answer-option:last-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Else"
    end

    expect(page).to have_select("Maximum number of choices", selected: "3")
  end

  it "allows switching translated field tabs after form failures" do
    click_button "Add question"
    click_button "Save"

    within ".questionnaire-question:first-of-type" do
      fill_in find_nested_form_field_locator("body_en"), with: "Bye"
      click_link "Català", match: :first

      fill_in find_nested_form_field_locator("body_ca"), with: "Adeu"
      click_link "English", match: :first

      expect(page).to have_nested_field("body_en", with: "Bye")
      expect(page).to have_no_selector(nested_form_field_selector("body_ca"))
      expect(page).to have_no_content("Adeu")
    end
  end

  context "when adding a multiple option question" do
    before do
      visit questionnaire_edit_path

      within "form.edit_questionnaire" do
        click_button "Add question"

        within ".questionnaire-question" do
          fill_in find_nested_form_field_locator("body_en"), with: "This is the first question"
        end

        expect(page).to have_no_content "Add answer option"
        expect(page).to have_no_select("Maximum number of choices")
      end
    end

    it "updates the free text option selector according to the selected question type" do
      expect(page).to have_no_selector("input[type=checkbox][id$=_free_text]")

      select "Multiple option", from: "Type"
      expect(page).to have_selector("input[type=checkbox][id$=_free_text]")

      select "Short answer", from: "Type"
      expect(page).to have_no_selector("input[type=checkbox][id$=_free_text]")

      select "Single option", from: "Type"
      expect(page).to have_selector("input[type=checkbox][id$=_free_text]")
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

      within(".questionnaire-question:last-of-type") do
        select "Multiple option", from: "Type"
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        select "Single option", from: "Type"
        expect(page).to have_no_select("Maximum number of choices")
      end
    end
  end
end
