# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has questionnaire" do
  context "when the user is not logged in" do
    it "does not allow answering the questionnaire" do
      visit questionnaire_public_path

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).not_to have_css(".form.answer-questionnaire")

      within ".questionnaire-question_readonly" do
        expect(page).to have_i18n_content(question.body)
      end

      expect(page).to have_content("Sign in with your account or sign up to answer the form.")
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    it "allows answering the questionnaire" do
      visit questionnaire_public_path

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      accept_confirm do
        click_button "Submit"
      end

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      visit questionnaire_public_path

      expect(page).to have_content("You have already answered this form.")
      expect(page).to have_no_i18n_content(question.body)
    end

    context "with multiple steps" do
      let!(:separator) { create(:questionnaire_question, questionnaire: questionnaire, position: 1, question_type: :separator) }
      let!(:question2) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }

      before do
        visit questionnaire_public_path
      end

      it "allows answering the first questionnaire" do
        expect(page).to have_content("STEP 1 OF 2")

        within ".answer-questionnaire__submit" do
          expect(page).to have_no_content("Back")
        end

        answer_first_questionnaire

        expect(page).to have_no_selector(".success.flash")
      end

      it "allows revisiting previously-answered questionnaires with my answers" do
        answer_first_questionnaire

        click_link "Back"

        expect(page).to have_content("STEP 1 OF 2")
        expect(page).to have_field("questionnaire_answers_0", with: "My first answer")
      end

      it "finishes the submission when answering the last questionnaire" do
        answer_first_questionnaire

        check "questionnaire_tos_agreement"
        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        visit questionnaire_public_path

        expect(page).to have_content("You have already answered this form.")
      end

      def answer_first_questionnaire
        expect(page).to have_no_selector("#questionnaire_tos_agreement")

        fill_in question.body["en"], with: "My first answer"
        within ".answer-questionnaire__submit" do
          click_link "Continue"
        end
        expect(page).to have_content("STEP 2 OF 2")
      end
    end

    it "requires confirmation when exiting mid-answering" do
      visit questionnaire_public_path

      fill_in question.body["en"], with: "My first answer"

      dismiss_confirm do
        page.find(".logo-wrapper a").click
      end

      expect(page).to have_current_path questionnaire_public_path
    end

    context "when the questionnaire has already been answered by someone else" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "single_option",
          position: 0,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        answer = create(:answer, id: 1, questionnaire: questionnaire, question: question)

        answer.choices.create!(
          answer_option: Decidim::Forms::AnswerOption.first,
          body: "Lalalilo"
        )
      end

      it "does not leak defaults from other answers" do
        visit questionnaire_public_path

        expect(page).to have_no_selector("input[type=radio]:checked")
      end
    end

    shared_examples_for "a correctly ordered questionnaire" do
      it "displays the questions ordered by position starting with one" do
        form_fields = all(".answer-questionnaire .row")

        expect(form_fields[0]).to have_i18n_content(question.body).and have_content("1. ")
        expect(form_fields[1]).to have_i18n_content(other_question.body).and have_content("2. ")
      end
    end

    context "and submitting a fresh form" do
      let!(:other_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 1) }

      before do
        visit questionnaire_public_path
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    context "and rendering a form after errors" do
      let!(:other_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 1) }

      before do
        visit questionnaire_public_path
        accept_confirm { click_button "Submit" }
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    shared_context "when a non multiple choice question is mandatory" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "short_answer",
          position: 0,
          mandatory: true
        )
      end

      before do
        visit questionnaire_public_path

        check "questionnaire_tos_agreement"
      end
    end

    describe "leaving a blank question (without js)", driver: :rack_test do
      include_context "when a non multiple choice question is mandatory"

      before do
        click_button "Submit"
      end

      it "submits the form and shows errors" do
        within ".alert.flash" do
          expect(page).to have_content("problem")
        end

        expect(page).to have_content("can't be blank")
      end
    end

    describe "leaving a blank question (with js)" do
      include_context "when a non multiple choice question is mandatory"

      before do
        accept_confirm { click_button "Submit" }
      end

      it "shows errors without submitting the form" do
        expect(page).to have_no_selector ".alert.flash"

        expect(page).to have_content("can't be blank")
      end
    end

    describe "leaving a blank multiple choice question" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "single_option",
          position: 0,
          mandatory: true,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit questionnaire_public_path

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }
      end

      it "submits the form and shows errors" do
        within ".alert.flash" do
          expect(page).to have_content("problem")
        end

        expect(page).to have_content("can't be blank")
      end
    end

    context "when a question has a rich text description" do
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0, description: "<b>This question is important</b>") }

      it "properly interprets HTML descriptions" do
        visit questionnaire_public_path

        expect(page).to have_selector("b", text: "This question is important")
      end
    end

    describe "free text options" do
      let(:answer_option_bodies) { Array.new(3) { Decidim::Faker::Localized.sentence } }

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: question_type,
          position: 1,
          options: [
            { "body" => answer_option_bodies[0] },
            { "body" => answer_option_bodies[1] },
            { "body" => answer_option_bodies[2], "free_text" => true }
          ]
        )
      end

      let!(:other_question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "multiple_option",
          max_choices: 2,
          position: 2,
          options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit questionnaire_public_path
      end

      context "when question is single_option type" do
        let(:question_type) { "single_option" }

        it "renders them as radio buttons with attached text fields disabled by default" do
          expect(page).to have_selector(".radio-button-collection input[type=radio]", count: 3)

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", disabled: true, count: 1)

          choose answer_option_bodies[2]["en"]

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", disabled: false, count: 1)
        end

        it "saves the free text in a separate field if submission correct" do
          choose answer_option_bodies[2]["en"]
          fill_in "questionnaire_answers_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(Decidim::Forms::Answer.first.choices.first.custom_body).to eq("Cacatua")
        end

        it "preserves the previous custom body if submission not correct" do
          check other_question.answer_options.first.body["en"]
          check other_question.answer_options.second.body["en"]
          check other_question.answer_options.third.body["en"]

          choose answer_option_bodies[2]["en"]
          fill_in "questionnaire_answers_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", with: "Cacatua")
        end
      end

      context "when question is multiple_option type" do
        let(:question_type) { "multiple_option" }

        it "renders them as check boxes with attached text fields disabled by default" do
          expect(page.first(".check-box-collection")).to have_selector("input[type=checkbox]", count: 3)

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: true, count: 1)

          check answer_option_bodies[2]["en"]

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", disabled: false, count: 1)
        end

        it "saves the free text in a separate field if submission correct" do
          check answer_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(Decidim::Forms::Answer.first.choices.first.custom_body).to eq("Cacatua")
        end

        it "preserves the previous custom body if submission not correct" do
          check "questionnaire_responses_1_choices_0_body"
          check "questionnaire_responses_1_choices_1_body"
          check "questionnaire_responses_1_choices_2_body"

          check answer_option_bodies[2]["en"]
          fill_in "questionnaire_responses_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_field("questionnaire_responses_0_choices_2_custom_body", with: "Cacatua")
        end
      end
    end

    context "when question type is long answer" do
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "long_answer") }

      it "renders the answer as a textarea" do
        visit questionnaire_public_path

        expect(page).to have_selector("textarea#questionnaire_answers_0")
      end
    end

    context "when question type is short answer" do
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "short_answer") }

      it "renders the answer as a text field" do
        visit questionnaire_public_path

        expect(page).to have_selector("input[type=text]#questionnaire_answers_0")
      end
    end

    context "when question type is single option" do
      let(:answer_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "single_option", options: answer_options) }

      it "renders answers as a collection of radio buttons" do
        visit questionnaire_public_path

        expect(page).to have_selector(".radio-button-collection input[type=radio]", count: 2)

        choose answer_options[0]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        visit questionnaire_public_path

        expect(page).to have_content("You have already answered this form.")
        expect(page).to have_no_i18n_content(question.body)
      end
    end

    context "when question type is multiple option" do
      let(:answer_options) { Array.new(3) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option", options: answer_options) }

      it "renders answers as a collection of radio buttons" do
        visit questionnaire_public_path

        expect(page).to have_selector(".check-box-collection input[type=checkbox]", count: 3)

        expect(page).to have_no_content("Max choices:")

        check answer_options[0]["body"][:en]
        check answer_options[1]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        visit questionnaire_public_path

        expect(page).to have_content("You have already answered this form.")
        expect(page).to have_no_i18n_content(question.body)
      end

      it "respects the max number of choices" do
        question.update!(max_choices: 2)

        visit questionnaire_public_path

        expect(page).to have_content("Max choices: 2")

        check answer_options[0]["body"][:en]
        check answer_options[1]["body"][:en]
        check answer_options[2]["body"][:en]

        expect(page).to have_content("too many choices")

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".alert.flash" do
          expect(page).to have_content("There was a problem answering")
        end

        expect(page).to have_content("are too many")

        uncheck answer_options[2]["body"][:en]

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end
      end
    end

    context "when question type is sorting" do
      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "sorting",
          options: [
            { "body" => "idiotas" },
            { "body" => "trates" },
            { "body" => "No" },
            { "body" => "por" },
            { "body" => "nos" }
          ]
        )
      end

      it "renders the question answers as a collection of check boxes sortable on click" do
        visit questionnaire_public_path

        expect(page).to have_selector(".sortable-check-box-collection input[type=checkbox]", count: 5)

        expect(page).to have_content("idiotas\ntrates\nNo\npor\nnos")

        check "No"
        check "nos"
        check "trates"
        check "por"
        check "idiotas"

        expect(page).to have_content("1. No\n2. nos\n3. trates\n4. por\n5. idiotas")
      end

      it "properly saves valid sortings" do
        visit questionnaire_public_path

        check "No"
        check "nos"
        check "trates"
        check "por"
        check "idiotas"

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(Decidim::Forms::Answer.first.choices.pluck(:position, :body)).to eq(
          [[0, "No"], [1, "nos"], [2, "trates"], [3, "por"], [4, "idiotas"]]
        )
      end

      it "displays errors on incomplete sortings" do
        visit questionnaire_public_path

        check "No"

        accept_confirm { click_button "Submit" }

        within ".alert.flash" do
          expect(page).to have_content("problem")
        end

        expect(page).to have_content("are not complete")
      end
    end

    context "when question type is matrix_single" do
      let(:matrix_rows) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:answer_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:mandatory) { false }

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "matrix_single",
          rows: matrix_rows,
          options: answer_options,
          mandatory: mandatory
        )
      end

      it "renders the question answers as a collection of radio buttons" do
        visit questionnaire_public_path

        expect(page).to have_selector(".radio-button-collection input[type=radio]", count: 4)

        expect(page).to have_content(matrix_rows.map { |row| row["body"]["en"] }.join("\n"))
        expect(page).to have_content(answer_options.map { |option| option["body"]["en"] }.join(" "))

        radio_buttons = page.all(".radio-button-collection input[type=radio]")

        choose radio_buttons.first[:id]
        choose radio_buttons.last[:id]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        visit questionnaire_public_path

        expect(page).to have_content("You have already answered this form.")
        expect(page).to have_no_i18n_content(question.body)

        first_choice, last_choice = Decidim::Forms::Answer.last.choices.pluck(:decidim_answer_option_id, :decidim_question_matrix_row_id)

        expect(first_choice).to eq([question.answer_options.first.id, question.matrix_rows.first.id])
        expect(last_choice).to eq([question.answer_options.last.id, question.matrix_rows.last.id])
      end

      it "preserves the chosen answers if submission not correct" do
        visit questionnaire_public_path

        radio_buttons = page.all(".radio-button-collection input[type=radio]")
        choose radio_buttons[1][:id]

        accept_confirm { click_button "Submit" }

        within ".alert.flash" do
          expect(page).to have_content("There was a problem answering")
        end

        radio_buttons = page.all(".radio-button-collection input[type=radio]")
        expect(radio_buttons.map { |b| b[:checked] }).to eq([nil, "true", nil, nil])
      end

      context "when the question is mandatory and the answer is not complete" do
        let!(:mandatory) { true }

        it "shows an error if the question is mandatory and the answer is not complete" do
          visit questionnaire_public_path

          radio_buttons = page.all(".radio-button-collection input[type=radio]")
          choose radio_buttons[0][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_content("Choices are not complete")
        end
      end
    end

    context "when question type is matrix_multiple" do
      let(:matrix_rows) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:answer_options) { Array.new(3) { { "body" => Decidim::Faker::Localized.sentence } } }
      let(:max_choices) { nil }
      let(:mandatory) { false }

      let!(:question) do
        create(
          :questionnaire_question,
          questionnaire: questionnaire,
          question_type: "matrix_multiple",
          rows: matrix_rows,
          options: answer_options,
          max_choices: max_choices,
          mandatory: mandatory
        )
      end

      it "renders the question answers as a collection of check boxes" do
        visit questionnaire_public_path

        expect(page).to have_selector(".check-box-collection input[type=checkbox]", count: 6)

        expect(page).to have_content(matrix_rows.map { |row| row["body"]["en"] }.join("\n"))
        expect(page).to have_content(answer_options.map { |option| option["body"]["en"] }.join(" "))

        checkboxes = page.all(".check-box-collection input[type=checkbox]")

        check checkboxes[0][:id]
        check checkboxes[1][:id]
        check checkboxes[3][:id]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        visit questionnaire_public_path

        expect(page).to have_content("You have already answered this form.")
        expect(page).to have_no_i18n_content(question.body)

        first_choice, second_choice, third_choice = Decidim::Forms::Answer.last.choices.pluck(:decidim_answer_option_id, :decidim_question_matrix_row_id)

        expect(first_choice).to eq([question.answer_options.first.id, question.matrix_rows.first.id])
        expect(second_choice).to eq([question.answer_options.second.id, question.matrix_rows.first.id])
        expect(third_choice).to eq([question.answer_options.first.id, question.matrix_rows.last.id])
      end

      context "when the question hax max_choices defined" do
        let!(:max_choices) { 2 }

        it "respects the max number of choices" do
          visit questionnaire_public_path

          expect(page).to have_content("Max choices: 2")

          checkboxes = page.all(".check-box-collection input[type=checkbox]")

          check checkboxes[0][:id]
          check checkboxes[1][:id]
          check checkboxes[2][:id]

          expect(page).to have_content("too many choices")

          check checkboxes[3][:id]
          check checkboxes[4][:id]

          expect(page).to have_content("too many choices")

          check checkboxes[5][:id]

          uncheck checkboxes[0][:id]

          expect(page).to have_content("too many choices")

          check "questionnaire_tos_agreement"

          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_content("are too many")

          checkboxes = page.all(".check-box-collection input[type=checkbox]")

          uncheck checkboxes[5][:id]

          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end
        end
      end

      context "when the submission is not correct" do
        let!(:max_choices) { 2 }

        it "preserves the chosen answers" do
          visit questionnaire_public_path

          checkboxes = page.all(".check-box-collection input[type=checkbox]")
          check checkboxes[0][:id]
          check checkboxes[1][:id]
          check checkboxes[2][:id]
          check checkboxes[5][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          checkboxes = page.all(".check-box-collection input[type=checkbox]")
          expect(checkboxes.map { |c| c[:checked] }).to eq(["true", "true", "true", nil, nil, "true"])
        end
      end

      context "when the question is mandatory and the answer is not complete" do
        let!(:mandatory) { true }

        it "shows an error" do
          visit questionnaire_public_path

          checkboxes = page.all(".check-box-collection input[type=checkbox]")
          check checkboxes[0][:id]

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_content("Choices are not complete")
        end
      end
    end
  end
end
