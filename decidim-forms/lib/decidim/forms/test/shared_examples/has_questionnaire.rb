# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has questionnaire" do
  context "when the user is not logged in" do
    it "does not allow answering the questionnaire" do
      visit_component

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      expect(page).to have_no_i18n_content(question.body)

      expect(page).to have_content("Sign in with your account or sign up to answer the questionnaire.")
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    it "allows answering the questionnaire" do
      visit_component

      expect(page).to have_i18n_content(questionnaire.title, upcase: true)
      expect(page).to have_i18n_content(questionnaire.description)

      fill_in question.body["en"], with: "My first answer"

      check "questionnaire_tos_agreement"

      accept_confirm { click_button "Submit" }

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("You have already answered this questionnaire.")
      expect(page).to have_no_i18n_content(question.body)
    end

    context "when the questionnaire has already been answered by someone else" do
      let!(:question) do
        create(
          :question,
          questionnaire: questionnaire,
          question_type: "single_option",
          position: 0,
          answer_options: [
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
        visit_component

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
      let!(:other_question) { create(:question, questionnaire: questionnaire, position: 1) }

      before do
        visit_component
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    context "and rendering a form after errors" do
      let!(:other_question) { create(:question, questionnaire: questionnaire, position: 1) }

      before do
        visit_component
        accept_confirm { click_button "Submit" }
      end

      it_behaves_like "a correctly ordered questionnaire"
    end

    shared_context "when a non multiple choice question is mandatory" do
      let!(:question) do
        create(
          :question,
          questionnaire: questionnaire,
          question_type: "short_answer",
          position: 0,
          mandatory: true
        )
      end

      before do
        visit_component

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
          expect(page).to have_content("error")
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
          :question,
          questionnaire: questionnaire,
          question_type: "single_option",
          position: 0,
          mandatory: true,
          answer_options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit_component

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }
      end

      it "submits the form and shows errors" do
        within ".alert.flash" do
          expect(page).to have_content("error")
        end

        expect(page).to have_content("can't be blank")
      end
    end

    context "when a question has a rich text description" do
      let!(:question) { create(:question, questionnaire: questionnaire, position: 0, description: "<b>This question is important</b>") }

      it "properly interprets HTML descriptions" do
        visit_component

        expect(page).to have_selector("b", text: "This question is important")
      end
    end

    describe "free text options" do
      let(:answer_option_bodies) { Array.new(3) { Decidim::Faker::Localized.sentence } }

      let!(:question) do
        create(
          :question,
          questionnaire: questionnaire,
          question_type: question_type,
          answer_options: [
            { "body" => answer_option_bodies[0] },
            { "body" => answer_option_bodies[1] },
            { "body" => answer_option_bodies[2], "free_text" => true }
          ]
        )
      end

      let!(:other_question) do
        create(
          :question,
          questionnaire: questionnaire,
          question_type: "multiple_option",
          max_choices: 2,
          answer_options: [
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence },
            { "body" => Decidim::Faker::Localized.sentence }
          ]
        )
      end

      before do
        visit_component
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
            expect(page).to have_content("There's been errors when answering")
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
            expect(page).to have_content("There's been errors when answering")
          end

          expect(page).to have_field("questionnaire_answers_0_choices_2_custom_body", with: "Cacatua")
        end
      end
    end

    context "when question type is long answer" do
      let!(:question) { create(:question, questionnaire: questionnaire, question_type: "long_answer") }

      it "renders the answer as a textarea" do
        visit_component

        expect(page).to have_selector("textarea#questionnaire_answers_0")
      end
    end

    context "when question type is short answer" do
      let!(:question) { create(:question, questionnaire: questionnaire, question_type: "short_answer") }

      it "renders the answer as a text field" do
        visit_component

        expect(page).to have_selector("input[type=text]#questionnaire_answers_0")
      end
    end

    context "when question type is single option" do
      let(:answer_options) { Array.new(2) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:question, questionnaire: questionnaire, question_type: "single_option", answer_options: answer_options) }

      it "renders answers as a collection of radio buttons" do
        visit_component

        expect(page).to have_selector(".radio-button-collection input[type=radio]", count: 2)

        choose answer_options[0]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_content("You have already answered this questionnaire.")
        expect(page).to have_no_i18n_content(question.body)
      end
    end

    context "when question type is multiple option" do
      let(:answer_options) { Array.new(3) { { "body" => Decidim::Faker::Localized.sentence } } }
      let!(:question) { create(:question, questionnaire: questionnaire, question_type: "multiple_option", answer_options: answer_options) }

      it "renders answers as a collection of radio buttons" do
        visit_component

        expect(page).to have_selector(".check-box-collection input[type=checkbox]", count: 3)

        expect(page).to have_no_content("Max choices:")

        check answer_options[0]["body"][:en]
        check answer_options[1]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_content("You have already answered this questionnaire.")
        expect(page).to have_no_i18n_content(question.body)
      end

      it "respects the max number of choices" do
        question.update!(max_choices: 2)

        visit_component

        expect(page).to have_content("Max choices: 2")

        check answer_options[0]["body"][:en]
        check answer_options[1]["body"][:en]
        check answer_options[2]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".alert.flash" do
          expect(page).to have_content("There's been errors")
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
      let!(:question) { create(:question, questionnaire: questionnaire, question_type: "multiple_option", answer_options: answer_options) }

      it "renders the question answers as a collection of radio buttons" do
        visit_component

        expect(page).to have_selector(".check-box-collection input[type=checkbox]", count: 2)

        check answer_options[0]["body"][:en]
        check answer_options[1]["body"][:en]

        check "questionnaire_tos_agreement"

        accept_confirm { click_button "Submit" }

        within ".success.flash" do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_content("You have already answered this questionnaire.")
        expect(page).to have_no_i18n_content(question.body)
      end
    end

    context "when question type is sorting" do
      let!(:question) do
        create(
          :question,
          questionnaire: questionnaire,
          question_type: "sorting",
          answer_options: [
            { "body" => "idiotas" },
            { "body" => "trates" },
            { "body" => "No" },
            { "body" => "por" },
            { "body" => "nos" }
          ]
        )
      end

      it "renders the question answers as a collection of check boxes sortable on click" do
        visit_component

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
        visit_component

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
        visit_component

        check "No"

        accept_confirm { click_button "Submit" }

        within ".alert.flash" do
          expect(page).to have_content("error")
        end

        expect(page).to have_content("are not complete")
      end
    end
  end
end
