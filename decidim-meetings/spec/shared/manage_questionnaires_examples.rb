# frozen_string_literal: true

shared_examples "manage questionnaires" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  context "when questionnaire is already created" do
    let!(:questionnaire) { create(:questionnaire, meeting: meeting) }

    it "updates the questionnaire" do
      page.driver.browser.navigate.refresh

      visit_registration_form

      new_description = {
        en: "<p>New description</p>",
        ca: "<p>Nova descripció</p>",
        es: "<p>Nueva descripción</p>"
      }.stringify_keys

      within ".edit_questionnaire" do
        fill_in_i18n_editor(
          :questionnaire_description,
          "#questionnaire-description-tabs",
          new_description
        )
        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully updated")

      questionnaire.reload
      expect(questionnaire.description).to eq(new_description)
    end
  end

  context "when questionnaire is not created" do
    it "creates the questionnaire" do
      visit_registration_form

      within ".new_questionnaire" do
        fill_in_i18n(
          :questionnaire_title,
          "#questionnaire-title-tabs",
          en: "Registration form",
          es: "Formulario de registro",
          ca: "Formulari de registre"
        )

        fill_in_i18n_editor(
          :questionnaire_description,
          "#questionnaire-description-tabs",
          en: "Description text",
          es: "Texto descriptivo",
          ca: "Text descriptiu"
        )

        fill_in_i18n_editor(
          :questionnaire_tos,
          "#questionnaire-tos-tabs",
          en: "Privacy",
          es: "Privacidad",
          ca: "Privacitat"
        )
        click_button "Create"
      end

      expect(page).to have_admin_callout("successfully created")
    end
  end

  context "when the questionnaire is not already answered" do
    let!(:questionnaire) { create(:questionnaire, meeting: meeting) }

    before do
      visit_registration_form
    end

    it "adds a few questions to the questionnaire" do
      questions_body = ["This is the first question", "This is the second question"]

      within "form.edit_questionnaire" do
        2.times { click_button "Add question" }

        expect(page).to have_selector(".questionnaire-question", count: 2)

        page.all(".questionnaire-question").each_with_index do |questionnaire_question, idx|
          within questionnaire_question do
            fill_in find_nested_form_field_locator("body_en"), with: questions_body[idx]
          end
        end

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")

      visit_registration_form

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

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")
    end

    it "adds a question with answer options" do
      question_body = "This is the first question"
      answer_options_body = ["This is the first option", "This is the second option"]

      within "form.edit_questionnaire" do
        click_button "Add question"

        within ".questionnaire-question" do
          fill_in find_nested_form_field_locator("body_en"), with: question_body
        end

        expect(page).to have_no_content "Add answer option"

        select "Single option", from: "Question type"

        page.all(".questionnaire-question-answer-option").each_with_index do |questionnaire_question_answer_option, idx|
          within questionnaire_question_answer_option do
            fill_in find_nested_form_field_locator("body_en"), with: answer_options_body[idx]
          end
        end

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")

      visit_registration_form

      expect(page).to have_selector("input[value='This is the first question']")
      expect(page).to have_selector("input[value='This is the first option']")
      expect(page).to have_selector("input[value='This is the second option']")
    end

    it "adds a sane number of options for each attribute type" do
      click_button "Add question"

      select "Long answer", from: "Question type"
      expect(page).to have_no_selector(".questionnaire-question-answer-option")

      select "Single option", from: "Question type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

      select "Multiple option", from: "Question type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

      select "Single option", from: "Question type"
      expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)

      select "Short answer", from: "Question type"
      expect(page).to have_no_selector(".questionnaire-question-answer-option")
    end

    it "does not incorrectly reorder when clicking answer options" do
      click_button "Add question"
      select "Single option", from: "Question type"
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
      select "Long answer", from: "Question type"
      click_button "Update"

      expect(page).to have_select("Question type", selected: "Long answer")
    end

    it "does not preserve spurious answer options from previous type selections" do
      click_button "Add question"
      select "Single option", from: "Question type"

      within ".questionnaire-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      select "Long answer", from: "Question type"

      click_button "Update"

      select "Single option", from: "Question type"

      within ".questionnaire-question-answer-option:first-of-type" do
        expect(page).to have_no_nested_field("body_en", with: "Something")
      end
    end

    it "preserves answer options form across submission failures" do
      click_button "Add question"
      select "Multiple option", from: "Question type"

      within ".questionnaire-question-answer-option:first-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Something"
      end

      click_button "Add answer option"

      within ".questionnaire-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      select "3", from: "Max choices"

      click_button "Update"

      within ".questionnaire-question-answer-option:first-of-type" do
        expect(page).to have_nested_field("body_en", with: "Something")
      end

      within ".questionnaire-question-answer-option:last-of-type" do
        fill_in find_nested_form_field_locator("body_en"), with: "Else"
      end

      expect(page).to have_select("Max choices", selected: "3")
    end

    it "allows switching translated field tabs after form failures" do
      click_button "Add question"
      click_button "Update"

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
        visit_registration_form

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

        select "Multiple option", from: "Question type"
        expect(page).to have_selector("input[type=checkbox][id$=_free_text]")

        select "Short answer", from: "Question type"
        expect(page).to have_no_selector("input[type=checkbox][id$=_free_text]")

        select "Single option", from: "Question type"
        expect(page).to have_selector("input[type=checkbox][id$=_free_text]")
      end

      it "updates the max choices selector according to the configured options" do
        expect(page).to have_no_select("Maximum number of choices")

        select "Multiple option", from: "Question type"
        expect(page).to have_select("Max choices", options: %w(Any 2))

        click_button "Add answer option"
        expect(page).to have_select("Max choices", options: %w(Any 2 3))

        click_button "Add answer option"
        expect(page).to have_select("Max choices", options: %w(Any 2 3 4))

        within(".questionnaire-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Max choices", options: %w(Any 2 3))

        within(".questionnaire-question-answer-option:last-of-type") { click_button "Remove" }
        expect(page).to have_select("Max choices", options: %w(Any 2))

        click_button "Add question"

        within(".questionnaire-question:last-of-type") do
          select "Multiple option", from: "Question type"
          expect(page).to have_select("Max choices", options: %w(Any 2))

          select "Single option", from: "Question type"
          expect(page).to have_no_select("Max choices")
        end
      end
    end

    context "when a questionnaire has an existing question" do
      let!(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, body: body) }

      before do
        visit_registration_form
      end

      it "modifies the question when the information is valid" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            fill_in "questionnaire_questions_#{questionnaire_question.id}_body_en", with: "Modified question"
            check "Mandatory"
            select "Long answer", from: "Question type"
          end

          click_button "Update"
        end

        expect(page).to have_admin_callout("successfully")

        visit_registration_form

        expect(page).to have_selector("input[value='Modified question']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#questionnaire_questions_#{questionnaire_question.id}_mandatory[checked]")
        expect(page).to have_selector("select#questionnaire_questions_#{questionnaire_question.id}_question_type option[value='long_answer'][selected]")
      end

      it "re-renders the form when the information is invalid and displays errors" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            expect(page).to have_content("Statement*")
            fill_in "questionnaire_questions_#{questionnaire_question.id}_body_en", with: ""
            check "Mandatory"
            select "Multiple option", from: "Question type"
            select "2", from: "Max choices"
          end

          click_button "Update"
        end

        expect(page).to have_admin_callout("There's been a problem updating this questionnaire")
        expect(page).to have_content("can't be blank", count: 3) # empty question, 2 empty default answer options

        expect(page).to have_selector("input[value='']")
        expect(page).to have_no_selector("input[value='This is the first question']")
        expect(page).to have_selector("input#questionnaire_questions_#{questionnaire_question.id}_mandatory[checked]")
        expect(page).to have_select("Max choices", selected: "2")
        expect(page).to have_selector("select#questionnaire_questions_#{questionnaire_question.id}_question_type option[value='multiple_option'][selected]")
      end

      it "preserves deleted status across submission failures" do
        within "form.edit_questionnaire" do
          within ".questionnaire-question" do
            click_button "Remove"
          end
        end

        click_button "Add question"

        click_button "Update"

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

          click_button "Update"
        end

        expect(page).to have_admin_callout("successfully")

        visit_registration_form

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
      let!(:questionnaire_question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
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
        visit_registration_form
      end

      it "allows deleting answer options" do
        within ".questionnaire-question-answer-option:last-of-type" do
          click_button "Remove"
        end

        click_button "Update"

        visit_registration_form

        expect(page).to have_selector(".questionnaire-question-answer-option", count: 2)
      end

      it "still removes the question even if previous editions rendered the options invalid" do
        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 1)

          within ".questionnaire-question-answer-option:first-of-type" do
            fill_in find_nested_form_field_locator("body_en"), with: ""
          end

          within ".questionnaire-question" do
            click_button "Remove", match: :first
          end

          click_button "Update"
        end

        expect(page).to have_admin_callout("successfully")

        visit_registration_form

        within "form.edit_questionnaire" do
          expect(page).to have_selector(".questionnaire-question", count: 0)
        end
      end
    end

    context "when a questionnaire has multiple existing questions" do
      let!(:questionnaire_question_1) do
        create(:questionnaire_question, questionnaire: questionnaire, body: first_body, position: 0)
      end

      let!(:questionnaire_question_2) do
        create(:questionnaire_question, questionnaire: questionnaire, body: second_body, position: 1)
      end

      let(:first_body) do
        { en: "First", ca: "Primera", es: "Primera" }
      end

      let(:second_body) do
        { en: "Second", ca: "Segunda", es: "Segunda" }
      end

      before do
        visit_registration_form
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

          it_behaves_like "switching questions order"
        end
      end

      context "when moving a question down" do
        before do
          within ".questionnaire-question:first-of-type" do
            click_button "Down"
          end
        end

        it_behaves_like "switching questions order"
      end

      it "properly decides which button to show after adding/removing questions" do
        click_button "Add question"

        expect(page.find(".questionnaire-question:nth-child(1)")).to look_like_first_question
        expect(page.find(".questionnaire-question:nth-child(2)")).to look_like_intermediate_question
        expect(page.find(".questionnaire-question:nth-child(3)")).to look_like_last_question

        within ".questionnaire-question:first-of-type" do
          click_button "Remove"
        end

        expect(page.all(".questionnaire-question").first).to look_like_first_question
        expect(page.all(".questionnaire-question").last).to look_like_last_question
      end

      it "does not duplicate editors when adding new questions" do
        expect { click_button "Add question" }.to change { page.all(".ql-toolbar").size }.by(1)
      end

      it "properly decides which button to show after adding/removing answer options" do
        click_button "Add question"

        within ".questionnaire-question:last-of-type" do
          select "Single option", from: "Question type"

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

        click_button "Update"

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
    let!(:questionnaire) { create(:questionnaire, meeting: meeting) }
    let!(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, body: body, question_type: "multiple_option") }
    let!(:questionnaire_answer) { create(:questionnaire_answer, questionnaire: questionnaire, question: questionnaire_question) }

    it "cannot modify questionnaire questions" do
      visit_registration_form

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

  def visit_registration_form
    visit_component_admin

    within find("tr", text: translated(meeting.title)) do
      page.click_link "Registrations"
    end

    page.click_link "Registration form"
  end
end
