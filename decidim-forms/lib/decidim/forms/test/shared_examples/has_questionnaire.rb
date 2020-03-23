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

      accept_confirm { click_button "Submit" }

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      visit questionnaire_public_path

      expect(page).to have_content("You have already answered this form.")
      expect(page).to have_no_i18n_content(question.body)
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

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", disabled: true, count: 1)

          check answer_option_bodies[2]["en"]

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", disabled: false, count: 1)
        end

        it "saves the free text in a separate field if submission correct" do
          check answer_option_bodies[2]["en"]
          fill_in "questionnaire_answers_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".success.flash" do
            expect(page).to have_content("successfully")
          end

          expect(Decidim::Forms::Answer.first.choices.first.custom_body).to eq("Cacatua")
        end

        it "preserves the previous custom body if submission not correct" do
          check "questionnaire_answers_1_choices_0_body"
          check "questionnaire_answers_1_choices_1_body"
          check "questionnaire_answers_1_choices_2_body"

          check answer_option_bodies[2]["en"]
          fill_in "questionnaire_answers_0_choices_2_custom_body", with: "Cacatua"

          check "questionnaire_tos_agreement"
          accept_confirm { click_button "Submit" }

          within ".alert.flash" do
            expect(page).to have_content("There was a problem answering")
          end

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", with: "Cacatua")
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

    context "when question type is multiple option" do
      let(:answer_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option", options: answer_options) }

      it "renders the question answers as a collection of radio buttons" do
        visit questionnaire_public_path

        expect(page).to have_selector(".check-box-collection input[type=checkbox]", count: 2)

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

    describe "display conditions" do
      let(:answer_options) do
        3.times.to_a.map do |x|
          {
            "body" => Decidim::Faker::Localized.sentence,
            "free_text" => x == 2
          }
        end
      end
      let(:condition_question_options) { [] }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }
      let!(:conditioned_question_id) { "#questionnaire_answers_1" }
      let!(:condition_question) do
        create(:questionnaire_question,
               questionnaire: questionnaire,
               question_type: condition_question_type,
               position: 1,
               options: condition_question_options)
      end

      context "when a question has a display condition" do
        context "when condition is of type 'answered'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "answered",
                   question: question,
                   condition_question: condition_question)
          end

          before do
            visit questionnaire_public_path
          end

          context "when the condition_question type is short answer" do
            let!(:condition_question_type) { "short_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: ""
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is long answer" do
            let!(:condition_question_type) { "long_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: ""
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'not_answered'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "not_answered",
                   question: question,
                   condition_question: condition_question)
          end

          before do
            visit questionnaire_public_path
          end

          context "when the condition_question type is short answer" do
            let!(:condition_question_type) { "short_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: ""
              change_focus

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is long answer" do
            let!(:condition_question_type) { "long_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: ""
              change_focus

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              choose condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(true)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)

              uncheck condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'equal'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "equal",
                   question: question,
                   condition_question: condition_question,
                   answer_option: condition_question.answer_options.first)
          end

          before do
            visit questionnaire_public_path
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'not_equal'" do
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "not_equal",
                   question: question,
                   condition_question: condition_question,
                   answer_option: condition_question.answer_options.first)
          end

          before do
            visit questionnaire_public_path
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(true)

              choose condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { answer_options }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(true)

              uncheck condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(false)

              check condition_question.answer_options.second.body["en"]

              expect_question_to_be_visible(true)
            end
          end
        end

        context "when a question has a display condition of type 'match'" do
          let!(:condition_value) { { en: "something" } }
          let!(:display_condition) do
            create(:display_condition,
                   condition_type: "match",
                   question: question,
                   condition_question: condition_question,
                   condition_value: condition_value)
          end

          before do
            visit questionnaire_public_path
          end

          context "when the condition_question type is short answer" do
            let!(:condition_question_type) { "short_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: "Aren't we all expecting #{condition_value[:en]}?"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Now upcase #{condition_value[:en].upcase}!"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is long answer" do
            let!(:condition_question_type) { "long_answer" }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              fill_in "questionnaire_answers_0", with: "Aren't we all expecting #{condition_value[:en]}?"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Now upcase #{condition_value[:en].upcase}!"
              change_focus

              expect_question_to_be_visible(true)

              fill_in "questionnaire_answers_0", with: "Cacatua"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is single option" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }
            let!(:condition_value) { { en: condition_question.answer_options.first.body["en"].split.second.upcase } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.first.body["en"]

              expect_question_to_be_visible(true)
            end
          end

          context "when the condition_question type is single option with free text" do
            let!(:condition_question_type) { "single_option" }
            let!(:condition_question_options) { answer_options }
            let!(:condition_value) { { en: "forty two" } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.third.body["en"]
              fill_in "questionnaire_answers_0_choices_2_custom_body", with: "The answer is #{condition_value[:en]}"
              change_focus

              expect_question_to_be_visible(true)

              choose condition_question.answer_options.first.body["en"]
              expect_question_to_be_visible(false)

              choose condition_question.answer_options.third.body["en"]
              fill_in "questionnaire_answers_0_choices_2_custom_body", with: "oh no not 42 again"
              change_focus

              expect_question_to_be_visible(false)
            end
          end

          context "when the condition_question type is multiple option" do
            let!(:condition_question_type) { "multiple_option" }
            let!(:condition_question_options) { answer_options }
            let!(:condition_value) { { en: "forty two" } }

            it "shows the question only if the condition is fulfilled" do
              expect_question_to_be_visible(false)

              check condition_question.answer_options.third.body["en"]
              fill_in "questionnaire_answers_0_choices_2_custom_body", with: "The answer is #{condition_value[:en]}"
              change_focus

              expect_question_to_be_visible(true)

              check condition_question.answer_options.first.body["en"]
              expect_question_to_be_visible(true)

              uncheck condition_question.answer_options.third.body["en"]
              expect_question_to_be_visible(false)

              check condition_question.answer_options.third.body["en"]
              fill_in "questionnaire_answers_0_choices_2_custom_body", with: "oh no not 42 again"
              change_focus

              expect_question_to_be_visible(false)
            end
          end
        end
      end

      context "when a question has multiple display conditions" do
        before do
          visit questionnaire_public_path
        end

        context "when all conditions are mandatory" do
          let!(:condition_question_type) { "single_option" }
          let!(:condition_question_options) { answer_options }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "answered",
                     question: question,
                     condition_question: condition_question,
                     mandatory: true),
              create(:display_condition,
                     condition_type: "not_equal",
                     question: question,
                     condition_question: condition_question,
                     mandatory: true,
                     answer_option: condition_question.answer_options.second)
            ]
          end

          it "is displayed only if all conditions are fulfilled" do
            expect_question_to_be_visible(false)

            choose condition_question.answer_options.second.body["en"]

            expect_question_to_be_visible(false)

            choose condition_question.answer_options.first.body["en"]

            expect_question_to_be_visible(true)
          end
        end

        context "when all conditions are non-mandatory" do
          let!(:condition_question_type) { "multiple_option" }
          let!(:condition_question_options) { answer_options }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "equal",
                     question: question,
                     condition_question: condition_question,
                     mandatory: false,
                     answer_option: condition_question.answer_options.first),
              create(:display_condition,
                     condition_type: "not_equal",
                     question: question,
                     condition_question: condition_question,
                     mandatory: false,
                     answer_option: condition_question.answer_options.third)
            ]
          end

          it "is displayed if any of the conditions is fulfilled" do
            expect_question_to_be_visible(false)

            check condition_question.answer_options.first.body["en"]

            expect_question_to_be_visible(true)

            uncheck condition_question.answer_options.first.body["en"]
            check condition_question.answer_options.second.body["en"]

            expect_question_to_be_visible(true)

            check condition_question.answer_options.first.body["en"]

            expect_question_to_be_visible(true)
          end
        end

        context "when a mandatory question has conditions that have not been fulfilled" do
          let!(:condition_question_type) { "short_answer" }
          let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2, mandatory: true) }
          let!(:display_conditions) do
            [
              create(:display_condition,
                     condition_type: "match",
                     question: question,
                     condition_question: condition_question,
                     condition_value: { en: "hey", es: "ey", ca: "ei" },
                     mandatory: true)
            ]
          end

          it "doesn't throw error" do
            visit questionnaire_public_path

            fill_in condition_question.body["en"], with: "My first answer"

            check "questionnaire_tos_agreement"

            accept_confirm { click_button "Submit" }

            within ".success.flash" do
              expect(page).to have_content("successfully")
            end
          end
        end
      end

      private

      def expect_question_to_be_visible(visible)
        expect(page).to have_css(conditioned_question_id, visible: visible)
      end

      def change_focus
        check "questionnaire_tos_agreement"
      end
    end
  end
end
