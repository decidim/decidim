# frozen_string_literal: true

shared_examples_for "display conditions" do
  before do
    login_as user, scope: :user
  end

  def expect_question_to_be_visible(visible)
    expect(page).to have_css(conditioned_question_id, visible: visible)
  end

  def change_focus
    check "questionnaire_tos_agreement"
  end

  let!(:conditioned_question_id) { "#questionnaire_answers_1" }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }

  let!(:condition_question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: condition_question_type, position: 1, options: condition_question_options) }
  let(:condition_question_options) { [] }

  let(:answer_options) do
    3.times.to_a.map do |x|
      {
        "body" => Decidim::Faker::Localized.sentence,
        "free_text" => x == 2
      }
    end
  end

  context "when a question has a display condition" do
    context "when condition is of type 'answered'" do
      let!(:display_condition) { create(:display_condition, condition_type: "answered", question: question, condition_question: condition_question) }

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
      let!(:display_condition) { create(:display_condition, condition_type: "not_answered", question: question, condition_question: condition_question) }

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
      let!(:display_condition) { create(:display_condition, condition_type: "equal", question: question, condition_question: condition_question, answer_option: condition_question.answer_options.first) }

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
      let!(:display_condition) { create(:display_condition, condition_type: "not_equal", question: question, condition_question: condition_question, answer_option: condition_question.answer_options.first) }

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
      let!(:display_condition) { create(:display_condition, condition_type: "match", question: question, condition_question: condition_question, condition_value: condition_value) }

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
          create(:display_condition, condition_type: "answered", question: question, condition_question: condition_question, mandatory: true),
          create(:display_condition, condition_type: "not_equal", question: question, condition_question: condition_question, mandatory: true, answer_option: condition_question.answer_options.second)
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
          create(:display_condition, condition_type: "equal", question: question, condition_question: condition_question, mandatory: false, answer_option: condition_question.answer_options.first),
          create(:display_condition, condition_type: "not_equal", question: question, condition_question: condition_question, mandatory: false, answer_option: condition_question.answer_options.third)
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
    end
  end
end
