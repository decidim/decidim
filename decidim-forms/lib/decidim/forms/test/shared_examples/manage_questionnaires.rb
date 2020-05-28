# frozen_string_literal: true

require "spec_helper"

shared_examples_for "manage questionnaires" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  it "updates the questionnaire" do
    visit questionnaire_edit_path

    new_description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    within "form.edit_questionnaire" do
      fill_in_i18n_editor(:questionnaire_description, "#questionnaire-description-tabs", new_description)
      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit questionnaire_public_path

    expect(page).to have_content("New description")
  end

  context "when the questionnaire is not already answered" do
    before do
      visit questionnaire_edit_path
    end

    it "adds a few questions and separators to the questionnaire" do
      questions_body = ["This is the first question", "This is the second question"]

      within "form.edit_questionnaire" do
        click_button "Add question"
        click_button "Add separator"
        click_button "Add question"

        expect(page).to have_selector(".questionnaire-question", count: 3)

        expand_all_questions

        page.all(".questionnaire-question .collapsible").each_with_index do |question, idx|
          within question do
            fill_in find_nested_form_field_locator("body_en"), with: questions_body[idx]
          end
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the second question']")
      expect(page).to have_content("SEPARATOR #2")
    end

    it "adds a question with a rich text description" do
      within "form.edit_questionnaire" do
        click_button "Add question"
        expand_all_questions

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
        expand_all_questions

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

      select "Long answer", from: "Type"
      expect(page).to have_no_selector(".questionnaire-question-answer-option")
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Single option", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Multiple option", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Matrix (Multiple option)", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_selector(".questionnaire-question-matrix-row", count: 2)

      select "Short answer", from: "Type"
      expect(page).to have_no_selector(".questionnaire-question-answer-option")
      expect(page).to have_no_selector(".questionnaire-question-matrix-row")

      select "Matrix (Single option)", from: "Type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      expect(page).to have_selector(".questionnaire-question-matrix-row", count: 2)
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

    it "does not incorrectly reorder when clicking matrix rows" do
      # Unable to find visible select box "Type" that is not disabled and Unable to find input box with datalist completion "Type" that is not disabled

      click_button "Add question"
      expand_all_questions

      select "Matrix (Multiple option)", from: "Type"
      2.times { click_button "Add row" }

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
      click_button "Add question"
      expand_all_questions

      select "Long answer", from: "Type"
      click_button "Save"

      expand_all_questions
      expect(page).to have_select("Type", selected: "Long answer")
    end

    it "does not preserve spurious answer options from previous type selections" do
      click_button "Add question"
      expand_all_questions

      select "Single option", from: "Type"

      within ".questionnaire-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      select "Long answer", from: "Type"

      click_button "Save"
      expand_all_questions

      select "Single option", from: "Type"

      within ".questionnaire-question-answer-option:first-of-type" do
        expect(page).to have_no_nested_field("body_en", with: "Something")
      end
    end

    it "does not preserve spurious matrix rows from previous type selections" do
      click_button "Add question"
      expand_all_questions

      select "Matrix (Single option)", from: "Type"

      within ".questionnaire-question-matrix-row:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      select "Long answer", from: "Type"

      click_button "Save"
      expand_all_questions

      select "Matrix (Single option)", from: "Type"

      within ".questionnaire-question-matrix-row:first-of-type" do
        expect(page).to have_no_nested_field("body_en", with: "Something")
      end
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

    it "preserves matrix rows form across submission failures" do
      click_button "Add question"
      expand_all_questions

      select "Matrix (Multiple option)", from: "Type"

      within ".questionnaire-question-matrix-row:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      click_button "Add row"

      click_button "Save"
      expand_all_questions

      within ".questionnaire-question-matrix-row:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end
    end

    it "allows switching translated field tabs after form failures" do
      click_button "Add question"
      click_button "Save"

      expand_all_questions

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

          expand_all_questions

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
        expand_all_questions

        within(".questionnaire-question:last-of-type") do
          select "Multiple option", from: "Type"
          expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

          select "Single option", from: "Type"
          expect(page).to have_no_select("Maximum number of choices")
        end
      end
    end

    context "when adding a matrix question" do
      before do
        visit questionnaire_edit_path

        within "form.edit_questionnaire" do
          click_button "Add question"
          expand_all_questions

          within ".questionnaire-question" do
            fill_in find_nested_form_field_locator("body_en"), with: "This is the first question"
          end

          expect(page).to have_no_content "Add answer option"
          expect(page).to have_no_content "Add row"
          expect(page).to have_no_select("Maximum number of choices")
        end
      end

      it "updates the free text option selector according to the selected question type" do
        expect(page).to have_no_selector("input[type=checkbox][id$=_free_text]")

        select "Matrix (Multiple option)", from: "Type"
        expect(page).to have_selector("input[type=checkbox][id$=_free_text]")

        select "Short answer", from: "Type"
        expect(page).to have_no_selector("input[type=checkbox][id$=_free_text]")

        select "Matrix (Single option)", from: "Type"
        expect(page).to have_selector("input[type=checkbox][id$=_free_text]")
      end

      it "updates the max choices selector according to the configured options" do
        expect(page).to have_no_select("Maximum number of choices")

        select "Matrix (Multiple option)", from: "Type"
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
          select "Matrix (Multiple option)", from: "Type"
          expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

          select "Matrix (Single option)", from: "Type"
          expect(page).to have_no_select("Maximum number of choices")
        end
      end
    end

    context "when a questionnaire has an existing question" do
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, body: body) }

      before do
        visit questionnaire_edit_path
        expand_all_questions
      end

      it "modifies the question when the information is valid" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            fill_in "questionnaire_questions_#{question.id}_body_en", with: "Modified question"
            check "Mandatory"
            select "Long answer", from: "Type"
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_questionnaire_edit_path_and_expand_all

        expect(page).to have_selector("input[value='Modified question']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#questionnaire_questions_#{question.id}_mandatory[checked]")
        expect(page).to have_selector("select#questionnaire_questions_#{question.id}_question_type option[value='long_answer'][selected]")
      end

      it "re-renders the form when the information is invalid and displays errors" do
        expand_all_questions

        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            expect(page).to have_content("Statement*")
            fill_in "questionnaire_questions_#{question.id}_body_en", with: ""
            check "Mandatory"
            select "Matrix (Multiple option)", from: "Type"
            select "2", from: "Maximum number of choices"
          end

          click_button "Save"
        end

        expand_all_questions

        expect(page).to have_admin_callout("There was a problem saving")
        expect(page).to have_content("can't be blank", count: 5) # emtpy question, 2 empty default answer options, 2 empty default matrix rows

        expect(page).to have_selector("input[value='']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#questionnaire_questions_#{question.id}_mandatory[checked]")
        expect(page).to have_select("Maximum number of choices", selected: "2")
        expect(page).to have_selector("select#questionnaire_questions_#{question.id}_question_type option[value='matrix_multiple'][selected]")
      end

      it "preserves deleted status across submission failures" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            click_button "Remove"
          end
        end

        click_button "Add question"

        click_button "Save"

        expect(page).to have_selector(".questionnaire-question", count: 1)

        within ".questionnaire-question" do
          expect(page).to have_selector(".card-title", text: "#1")
          expect(page).to have_no_button("Up")
        end
      end

      it "removes the question" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            click_button "Remove"
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit questionnaire_edit_path

        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 0)
        end
      end

      it "cannot be moved up" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            expect(page).to have_no_button("Up")
          end
        end
      end

      it "cannot be moved down" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            expect(page).to have_no_button("Down")
          end
        end
      end
    end

    context "when a questionnaire has an existing question with answer options" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          body: body,
          question_type: "single_option",
          options: [
            { "body" => { "en" => "cacarua" } },
            { "body" => { "en" => "cat" } },
            { "body" => { "en" => "dog" } }

          ]
        )
      end

      before do
        visit questionnaire_edit_path
      end

      it "allows deleting answer options" do
        expand_all_questions

        within ".questionnaire-question-answer-option:last-of-type" do
          click_button "Remove"
        end

        click_button "Save"

        visit_questionnaire_edit_path_and_expand_all

        expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      end

      it "still removes the question even if previous editions rendered the options invalid" do
        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 1)

          expand_all_questions

          within ".questionnaire-question-answer-option:first-of-type" do
            fill_in find_nested_form_field_locator("body_en"), with: ""
          end

          within ".questionnaire-question" do
            click_button "Remove", match: :first
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_questionnaire_edit_path_and_expand_all

        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 0)
        end
      end
    end

    context "when a questionnaire has an existing question with matrix rows" do
      let!(:other_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 1) }
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          body: body,
          question_type: "matrix_single",
          position: 2,
          options: [
            { "body" => { "en" => "cacarua" } },
            { "body" => { "en" => "cat" } },
            { "body" => { "en" => "dog" } }
          ],
          rows: [
            { "body" => { "en" => "cute" } },
            { "body" => { "en" => "ugly" } },
            { "body" => { "en" => "meh" } }
          ]
        )
      end

      before do
        visit_questionnaire_edit_path_and_expand_all
      end

      it "allows deleting matrix rows" do
        within ".questionnaire-question-matrix-row:last-of-type" do
          click_button "Remove"
        end

        click_button "Save"

        visit_questionnaire_edit_path_and_expand_all

        within ".questionnaire-question:last-of-type" do
          expect(page).to have_selector(".questionnaire-question-matrix-row", count: 2)
          expect(page).to have_selector(".questionnaire-question-answer-option", count: 3)
        end
      end

      it "still removes the question even if previous editions rendered the rows invalid" do
        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 2)

          within ".questionnaire-question-matrix-row:first-of-type" do
            fill_in find_nested_form_field_locator("body_en"), with: ""
          end

          within ".questionnaire-question:last-of-type" do
            click_button "Remove", match: :first
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_questionnaire_edit_path_and_expand_all

        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 1)
        end
      end
    end

    context "when a questionnaire has multiple existing questions" do
      let!(:question_1) do
        create(:questionnaire_question, questionnaire: questionnaire, body: first_body, position: 0)
      end

      let!(:question_2) do
        create(:questionnaire_question, questionnaire: questionnaire, body: second_body, position: 1)
      end

      let(:first_body) do
        { en: "First", ca: "Primera", es: "Primera" }
      end

      let(:second_body) do
        { en: "Second", ca: "Segunda", es: "Segunda" }
      end

      before do
        visit questionnaire_edit_path
        expand_all_questions
      end

      shared_examples_for "switching questions order" do
        it "properly reorders the questions" do
          within ".questionnaire-question:first-of-type" do
            expect(page).to have_nested_field("body_en", with: "Second")
            expect(page).to look_like_first_question
          end

          within ".questionnaire-question:last-of-type" do
            expect(page).to have_nested_field("body_en", with: "First")
            expect(page).to look_like_last_question
          end
        end
      end

      context "when moving a question up" do
        before do
          within ".questionnaire-question:last-of-type" do
            click_button "Up"
          end
        end

        it_behaves_like "switching questions order"
      end

      context "when moving a question down" do
        before do
          within ".questionnaire-question:first-of-type" do
            click_button "Down"
          end
        end

        it_behaves_like "switching questions order"
      end

      describe "collapsible questions" do
        context "when clicking on Expand all button" do
          it "expands all questions" do
            click_button "Expand all questions"
            expect(page).to have_selector(".collapsible", visible: true)
            expect(page).to have_selector(".question--collapse .icon-collapse", count: questionnaire.questions.count)
          end
        end

        context "when clicking on Collapse all button" do
          it "collapses all questions" do
            click_button "Collapse all questions"
            expect(page).not_to have_selector(".collapsible", visible: true)
            expect(page).to have_selector(".question--collapse .icon-expand", count: questionnaire.questions.count)
          end
        end

        shared_examples_for "collapsing a question" do
          it "changes the toggle button" do
            within ".questionnaire-question:last-of-type" do
              expect(page).to have_selector(".icon-expand")
            end
          end

          it "hides the question card section" do
            within ".questionnaire-question:last-of-type" do
              expect(page).not_to have_selector(".collapsible", visible: true)
            end
          end
        end

        shared_examples_for "uncollapsing a question" do
          it "changes the toggle button" do
            within ".questionnaire-question:last-of-type" do
              expect(page).to have_selector(".icon-collapse")
            end
          end

          it "shows the question card section" do
            expect(page).to have_selector(".collapsible", visible: true)
          end
        end

        context "when collapsing an existing question" do
          before do
            expand_all_questions
            within ".questionnaire-question:last-of-type" do
              page.find(".question--collapse").click
            end
          end

          it_behaves_like "collapsing a question"
        end

        context "when adding a new question" do
          before do
            click_button "Add question"
            expand_all_questions

            within ".questionnaire-question:last-of-type" do
              page.find(".question--collapse").click
            end
          end

          it_behaves_like "collapsing a question"
        end
      end

      it "properly decides which button to show after adding/removing questions" do
        click_button "Add question"
        expand_all_questions

        expect(page.find(".questionnaire-question:nth-of-type(1)")).to look_like_first_question
        expect(page.find(".questionnaire-question:nth-of-type(2)")).to look_like_intermediate_question
        expect(page.find(".questionnaire-question:nth-of-type(3)")).to look_like_last_question

        within ".questionnaire-question:first-of-type" do
          click_button "Remove"
        end

        expect(page.all(".questionnaire-question").first).to look_like_first_question
        expect(page.all(".questionnaire-question").last).to look_like_last_question
      end

      it "does not duplicate editors when adding new questions" do
        expect do
          click_button "Add question"
          expand_all_questions
        end.to change { page.all(".ql-toolbar").size }.by(1)
      end

      it "properly decides which button to show after adding/removing answer options" do
        click_button "Add question"
        expand_all_questions

        within ".questionnaire-question:last-of-type" do
          select "Single option", from: "Type"

          within ".questionnaire-question-answer-options-list" do
            expect(page).to have_no_button("Remove")
          end

          click_button "Add answer option"

          expect(page.all(".questionnaire-question-answer-option")).to all(have_button("Remove"))

          within ".questionnaire-question-answer-option:first-of-type" do
            click_button "Remove"
          end

          within ".questionnaire-question-answer-options-list" do
            expect(page).to have_no_button("Remove")
          end
        end

        click_button "Save"
        expand_all_questions

        within ".questionnaire-question:last-of-type" do
          within ".questionnaire-question-answer-options-list" do
            expect(page).to have_no_button("Remove")
          end
        end
      end

      private

      def look_like_first_question
        have_no_button("Up").and have_button("Down")
      end

      def look_like_intermediate_question
        have_button("Up").and have_button("Down")
      end

      def look_like_last_question
        have_button("Up").and have_no_button("Down")
      end
    end
  end

  context "when the questionnaire is already answered" do
    let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, body: body, question_type: "multiple_option") }
    let!(:answer) { create(:answer, questionnaire: questionnaire, question: question) }

    it "cannot modify questionnaire questions" do
      visit questionnaire_edit_path

      expect(page).to have_no_content("Add question")
      expect(page).to have_no_content("Remove")

      expand_all_questions

      expect(page).to have_selector("input[value='This is the first question'][disabled]")
      expect(page).to have_selector("select[id$=question_type][disabled]")
      expect(page).to have_selector("select[id$=max_choices][disabled]")
      expect(page).to have_selector(".ql-editor[contenteditable=false]")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: true)
    find_nested_form_field(attribute, visible: visible)["id"]
  end

  def find_nested_form_field(attribute, visible: true)
    current_scope.find(nested_form_field_selector(attribute), visible: visible)
  end

  def have_nested_field(attribute, with:)
    have_field find_nested_form_field_locator(attribute), with: with
  end

  def have_no_nested_field(attribute, with:)
    have_no_field(find_nested_form_field_locator(attribute), with: with)
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
end
