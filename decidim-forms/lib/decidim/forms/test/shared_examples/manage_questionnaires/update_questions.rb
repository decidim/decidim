# frozen_string_literal: true

require "spec_helper"

shared_examples_for "update questions" do
  context "when a questionnaire has an existing question" do
    let!(:question) { create(:questionnaire_question, questionnaire:, body:) }

    before do
      visit questionnaire_edit_path
      expand_all_questions
    end

    it "modifies the question when the information is valid" do
      within "form.edit_questionnaire" do
        within ".questionnaire-question" do
          fill_in "questionnaire_questions_#{question.id}_body_en", with: "Modified question"
          fill_in "questionnaire_questions_#{question.id}_max_characters", with: 30
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
      expect(page).to have_selector("input#questionnaire_questions_#{question.id}_max_characters[value='30']")
      expect(page).to have_selector("select#questionnaire_questions_#{question.id}_question_type option[value='long_answer'][selected]")
    end

    it "re-renders the form when the information is invalid and displays errors" do
      expand_all_questions

      within "form.edit_questionnaire" do
        within ".questionnaire-question" do
          expect(page).to have_content("Statement*")
          fill_in "questionnaire_questions_#{question.id}_body_en", with: ""
          fill_in "questionnaire_questions_#{question.id}_max_characters", with: -3
          check "Mandatory"
          select "Matrix (Multiple option)", from: "Type"
          select "2", from: "Maximum number of choices"
        end

        click_button "Save"
      end

      expand_all_questions

      expect(page).to have_admin_callout("There was a problem saving")
      expect(page).to have_content("can't be blank", count: 5) # emtpy question, 2 empty default answer options, 2 empty default matrix rows
      expect(page).to have_content("must be greater than or equal to 0", count: 1)

      expect(page).to have_selector("input[value='']")
      expect(page).to have_no_selector("input[value='This is the first question']")
      expect(page).to have_selector("input#questionnaire_questions_#{question.id}_mandatory[checked]")
      expect(page).to have_selector("input#questionnaire_questions_#{question.id}_max_characters[value='-3']")
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

  context "when a questionnaire has a title and description" do
    let!(:question) { create(:questionnaire_question, :title_and_description, questionnaire:, body: title_and_description_body) }

    before do
      visit questionnaire_edit_path
      expand_all_questions
    end

    it "modifies the question when the information is valid" do
      within "form.edit_questionnaire" do
        within ".questionnaire-question" do
          fill_in "questionnaire_questions_#{question.id}_body_en", with: "Modified title and description"
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_selector("input[value='Modified title and description']")
      expect(page).to have_no_selector("input[value='This is the first title and description']")
    end

    it "re-renders the form when the information is invalid and displays errors" do
      expand_all_questions

      within "form.edit_questionnaire" do
        within ".questionnaire-question" do
          fill_in "questionnaire_questions_#{question.id}_body_en", with: ""
        end

        click_button "Save"
      end

      expand_all_questions

      expect(page).to have_admin_callout("There was a problem saving")
      expect(page).to have_content("can't be blank", count: 1)
      expect(page).to have_selector("input[value='']")
      expect(page).to have_no_selector("input[value='This is the first title and description']")
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
        questionnaire:,
        body:,
        question_type: "single_option",
        options: [
          { "body" => { "en" => "cacatua" } },
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
    let!(:other_question) { create(:questionnaire_question, questionnaire:, position: 1) }
    let!(:question) do
      create(
        :questionnaire_question,
        questionnaire:,
        body:,
        question_type: "matrix_single",
        position: 2,
        options: [
          { "body" => { "en" => "cacatua" } },
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
    let!(:question1) do
      create(:questionnaire_question, questionnaire:, body: first_body, position: 0)
    end

    let!(:question2) do
      create(:questionnaire_question, questionnaire:, body: second_body, position: 1)
    end

    let(:first_body) do
      { en: "First", ca: "Primera", es: "Primera" }
    end

    let(:second_body) do
      { en: "Second", ca: "Segona", es: "Segunda" }
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
          expect(page).to have_selector(".collapsible", visible: :all)
          expect(page).to have_selector(".question--collapse .icon-collapse", count: questionnaire.questions.count)
        end
      end

      context "when clicking on Collapse all button" do
        it "collapses all questions" do
          click_button "Collapse all questions"
          expect(page).not_to have_selector(".collapsible", visible: :visible)
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
            expect(page).not_to have_selector(".collapsible", visible: :visible)
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
          expect(page).to have_selector(".collapsible", visible: :visible)
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

      context "when submitting a new question with an error" do
        before do
          click_button "Add question"
          click_button "Save"

          within ".questionnaire-question:last-of-type" do
            page.find(".question--collapse").click
          end
        end

        it_behaves_like "collapsing a question"

        it "can be expanded" do
          within ".questionnaire-question:last-of-type" do
            page.find(".question--collapse").click
          end

          within ".questionnaire-question:last-of-type" do
            expect(page).to have_selector(".icon-collapse")
          end
        end
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
