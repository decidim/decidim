# frozen_string_literal: true

shared_examples "edit surveys" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  it "updates the survey" do
    visit_component_admin

    new_description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    within "form.edit_survey" do
      fill_in_i18n_editor(:survey_description, "#survey-description-tabs", new_description)
      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit_component

    expect(page).to have_content("New description")
  end

  context "when the survey is not already answered" do
    it "adds a few questions to the survey" do
      visit_component_admin

      questions_body = ["This is the first question", "This is the second question"]

      within "form.edit_survey" do
        2.times { click_button "Add question" }

        expect(page).to have_selector(".survey-question", count: 2)

        page.all(".survey-question").each_with_index do |survey_question, idx|
          within survey_question do
            fill_in find_nested_form_field_locator("body_en"), with: questions_body[idx]
          end
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_component_admin

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the second question']")
    end

    it "adds a question with a rich text description" do
      visit_component_admin

      within "form.edit_survey" do
        click_button "Add question"

        within ".survey-question" do
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

      visit_component

      expect(page).to have_selector("strong", text: "Superkalifragilistic description")
    end

    it "adds a question with answer options" do
      visit_component_admin

      question_body = "This is the first question"
      answer_options_body = ["This is the first option", "This is the second option"]

      within "form.edit_survey" do
        click_button "Add question"

        within ".survey-question" do
          fill_in find_nested_form_field_locator("body_en"), with: question_body
        end

        expect(page).to have_no_content "Add answer option"

        select "Single option", from: "Type"

        page.all(".survey-question-answer-option").each_with_index do |survey_question_answer_option, idx|
          within survey_question_answer_option do
            fill_in find_nested_form_field_locator("body_en"), with: answer_options_body[idx]
          end
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_component_admin

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the first option']")
      expect(page).to have_selector("input[value='This is the second option']")
    end

    it "adds a sane number of options for each attribute type" do
      click_button "Add question"

      select "Long answer", from: "Type"
      expect(page).to have_no_selector(".survey-question-answer-option")

      select "Single option", from: "Type"
      expect(page).to have_selector(".survey-question-answer-option", count: 2)

      select "Multiple option", from: "Type"
      expect(page).to have_selector(".survey-question-answer-option", count: 2)

      select "Single option", from: "Type"
      expect(page).to have_selector(".survey-question-answer-option", count: 2)

      select "Short answer", from: "Type"
      expect(page).to have_no_selector(".survey-question-answer-option")
    end

    it "does not incorrectly reorder when clicking answer options" do
      click_button "Add question"
      select "Single option", from: "Type"
      2.times { click_button "Add answer option" }

      within ".survey-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      within ".survey-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      # If JS events for option reordering are incorrectly bound, clicking on
      # the field to gain focus can cause the options to get inverted... :S
      within ".survey-question-answer-option:first-of-type" do
        find_nested_form_field("body_en").click
      end

      within ".survey-question-answer-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".survey-question-answer-option:last-of-type" do
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

      within ".survey-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      select "Long answer", from: "Type"

      click_button "Save"

      select "Single option", from: "Type"

      within ".survey-question-answer-option:first-of-type" do
        expect(page).to have_no_nested_field("body_en", with: "Something")
      end
    end

    it "preserves answer options form across submission failures" do
      click_button "Add question"
      select "Multiple option", from: "Type"

      within ".survey-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      click_button "Add answer option"

      within ".survey-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      select "3", from: "Maximum number of choices"

      click_button "Save"

      within ".survey-question-answer-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".survey-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      expect(page).to have_select("Maximum number of choices", selected: "3")
    end

    it "allows switching translated field tabs after form failures" do
      click_button "Add question"
      click_button "Save"

      within ".survey-question:first-of-type" do
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
        visit_component_admin

        within "form.edit_survey" do
          click_button "Add question"

          within ".survey-question" do
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

        within(".survey-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2 3))

        within(".survey-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

        click_button "Add question"

        within(".survey-question:last-of-type") do
          select "Multiple option", from: "Type"
          expect(page).to have_select("Maximum number of choices", options: %w(Any 2))

          select "Single option", from: "Type"
          expect(page).to have_no_select("Maximum number of choices")
        end
      end
    end

    context "when a survey has an existing question" do
      let!(:survey_question) { create(:survey_question, survey: survey, body: body) }

      before do
        visit_component_admin
      end

      it "modifies the question when the information is valid" do
        within "form.edit_survey" do
          within ".survey-question" do
            fill_in "survey_questions_#{survey_question.id}_body_en", with: "Modified question"
            check "Mandatory"
            select "Long answer", from: "Type"
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_component_admin

        expect(page).to have_selector("input[value='Modified question']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#survey_questions_#{survey_question.id}_mandatory[checked]")
        expect(page).to have_selector("select#survey_questions_#{survey_question.id}_question_type option[value='long_answer'][selected]")
      end

      it "re-renders the form when the information is invalid and displays errors" do
        within "form.edit_survey" do
          within ".survey-question" do
            expect(page).to have_content("Statement*")
            fill_in "survey_questions_#{survey_question.id}_body_en", with: ""
            check "Mandatory"
            select "Multiple option", from: "Type"
            select "2", from: "Maximum number of choices"
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("There's been errors when saving the survey")
        expect(page).to have_content("can't be blank", count: 3) # emtpy question, 2 empty default answer options

        expect(page).to have_selector("input[value='']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#survey_questions_#{survey_question.id}_mandatory[checked]")
        expect(page).to have_select("Maximum number of choices", selected: "2")
        expect(page).to have_selector("select#survey_questions_#{survey_question.id}_question_type option[value='multiple_option'][selected]")
      end

      it "preserves deleted status across submission failures" do
        within "form.edit_survey" do
          within ".survey-question" do
            click_button "Remove"
          end
        end

        click_button "Add question"

        click_button "Save"

        expect(page).to have_selector(".survey-question", count: 1)

        within ".survey-question" do
          expect(page).to have_selector(".card-title", text: "#1")
          expect(page).to have_no_button("Up")
        end
      end

      it "removes the question" do
        within "form.edit_survey" do
          within ".survey-question" do
            click_button "Remove"
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_component_admin

        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 0)
        end
      end

      it "cannot be moved up" do
        within "form.edit_survey" do
          within ".survey-question" do
            expect(page).to have_no_button("Up")
          end
        end
      end

      it "cannot be moved down" do
        within "form.edit_survey" do
          within ".survey-question" do
            expect(page).to have_no_button("Down")
          end
        end
      end
    end

    context "when a survey has an existing question with answer options" do
      let!(:survey_question) do
        create(
          :survey_question,
          survey: survey,
          body: body,
          question_type: "single_option",
          answer_options: [
            { "body" => { "en" => "cacarua" } },
            { "body" => { "en" => "cat" } },
            { "body" => { "en" => "dog" } }

          ]
        )
      end

      before do
        visit_component_admin
      end

      it "allows deleting answer options" do
        within ".survey-question-answer-option:last-of-type" do
          click_button "Remove"
        end

        click_button "Save"

        visit_component_admin

        expect(page).to have_selector(".survey-question-answer-option", count: 2)
      end

      it "still removes the question even if previous editions rendered the options invalid" do
        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 1)

          within ".survey-question-answer-option:first-of-type" do
            fill_in find_nested_form_field_locator("body_en"), with: ""
          end

          within ".survey-question" do
            click_button "Remove", match: :first
          end

          click_button "Save"
        end

        expect(page).to have_admin_callout("successfully")

        visit_component_admin

        within "form.edit_survey" do
          expect(page).to have_selector(".survey-question", count: 0)
        end
      end
    end

    context "when a survey has multiple existing questions" do
      let!(:survey_question_1) do
        create(:survey_question, survey: survey, body: first_body, position: 0)
      end

      let!(:survey_question_2) do
        create(:survey_question, survey: survey, body: second_body, position: 1)
      end

      let(:first_body) do
        { en: "First", ca: "Primera", es: "Primera" }
      end

      let(:second_body) do
        { en: "Second", ca: "Segunda", es: "Segunda" }
      end

      before do
        visit_component_admin
      end

      shared_examples_for "switching questions order" do
        it "properly reorders the questions" do
          within ".survey-question:first-of-type" do
            expect(page).to have_nested_field("body_en", with: "Second")
            expect(page).to look_like_first_question
          end

          within ".survey-question:last-of-type" do
            expect(page).to have_nested_field("body_en", with: "First")
            expect(page).to look_like_last_question
          end
        end
      end

      context "when moving a question up" do
        before do
          within ".survey-question:last-of-type" do
            click_button "Up"
          end

          it_behaves_like "switching questions order"
        end
      end

      context "when moving a question down" do
        before do
          within ".survey-question:first-of-type" do
            click_button "Down"
          end
        end

        it_behaves_like "switching questions order"
      end

      it "properly decides which button to show after adding/removing questions" do
        click_button "Add question"

        expect(page.find(".survey-question:nth-child(1)")).to look_like_first_question
        expect(page.find(".survey-question:nth-child(2)")).to look_like_intermediate_question
        expect(page.find(".survey-question:nth-child(3)")).to look_like_last_question

        within ".survey-question:first-of-type" do
          click_button "Remove"
        end

        expect(page.all(".survey-question").first).to look_like_first_question
        expect(page.all(".survey-question").last).to look_like_last_question
      end

      it "does not duplicate editors when adding new questions" do
        expect { click_button "Add question" }.to change { page.all(".ql-toolbar").size }.by(1)
      end

      it "properly decides which button to show after adding/removing answer options" do
        click_button "Add question"

        within ".survey-question:last-of-type" do
          select "Single option", from: "Type"

          within ".survey-question-answer-options-list" do
            expect(page).to have_no_button("Remove")
          end

          click_button "Add answer option"

          expect(page.all(".survey-question-answer-option")).to all(have_button("Remove"))

          within ".survey-question-answer-option:first-of-type" do
            click_button "Remove"
          end

          within ".survey-question-answer-options-list" do
            expect(page).to have_no_button("Remove")
          end
        end

        click_button "Save"

        within ".survey-question:last-of-type" do
          within ".survey-question-answer-options-list" do
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

  context "when the survey is already answered" do
    let!(:survey_question) { create(:survey_question, survey: survey, body: body, question_type: "multiple_option") }
    let!(:survey_answer) { create(:survey_answer, survey: survey, question: survey_question) }

    it "cannot modify survey questions" do
      visit_component_admin

      expect(page).to have_no_content("Add question")
      expect(page).to have_no_content("Remove")
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
end
