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

  def answer_options
    3.times.to_a.map { |x| { "body" => Hash[[:en, :es, :ca].map { |key| [key, "Body #{x}"] }] } }
  end

  def condition_question_short_answer
    create(:questionnaire_question, questionnaire: questionnaire, question_type: "short_answer", position: 1)
  end

  def condition_question_long_answer
    create(:questionnaire_question, questionnaire: questionnaire, question_type: "long_answer", position: 1)
  end

  def condition_question_single_option
    create(:questionnaire_question, questionnaire: questionnaire, question_type: "single_option", position: 1, options: answer_options)
  end

  def condition_question_multiple_option
    create(:questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option", position: 1, options: answer_options)
  end

  context "when a question has a display condition" do
    let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }
    let!(:conditioned_question_id) { "#questionnaire_answers_1" }

    context "when condition is of type 'answered'" do
      let!(:display_condition) { create(:display_condition, condition_type: "answered", question: question, condition_question: condition_question) }

      before do
        visit questionnaire_public_path
      end

      context "when the condition_question type is short answer" do
        let!(:condition_question) { condition_question_short_answer }

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
        let!(:condition_question) { condition_question_long_answer }

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
        let!(:condition_question) { condition_question_single_option }

        it "shows the question only if the condition is fulfilled" do
          expect_question_to_be_visible(false)

          choose condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(true)

          choose condition_question.answer_options.second.body["en"]

          expect_question_to_be_visible(false)
        end
      end

      context "when the condition_question type is multiple option" do
        let!(:condition_question) { condition_question_multiple_option }

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
        let!(:condition_question) { condition_question_short_answer }

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
        let!(:condition_question) { condition_question_long_answer }

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
        let!(:condition_question) { condition_question_single_option }

        it "shows the question only if the condition is fulfilled" do
          expect_question_to_be_visible(true)

          choose condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(false)
        end
      end

      context "when the condition_question type is multiple option" do
        let!(:condition_question) { condition_question_multiple_option }

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
        let!(:condition_question) { condition_question_single_option }

        it "shows the question only if the condition is fulfilled" do
          expect_question_to_be_visible(false)

          choose condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(true)

          choose condition_question.answer_options.second.body["en"]

          expect_question_to_be_visible(false)
        end
      end

      context "when the condition_question type is multiple option" do
        let!(:condition_question) { condition_question_multiple_option }

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
        let!(:condition_question) { condition_question_single_option }

        it "shows the question only if the condition is fulfilled" do
          expect_question_to_be_visible(true)

          choose condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(false)

          choose condition_question.answer_options.second.body["en"]

          expect_question_to_be_visible(true)
        end
      end

      context "when the condition_question type is multiple option" do
        let!(:condition_question) { condition_question_multiple_option }

        it "shows the question only if the condition is fulfilled" do
          expect_question_to_be_visible(true)

          check condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(false)

          uncheck condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(true)

          check condition_question.answer_options.second.body["en"]

          expect_question_to_be_visible(true)

          check condition_question.answer_options.first.body["en"]

          expect_question_to_be_visible(false)
        end
      end
    end

    context "when a question has a display condition of type 'match'" do
      context "when the condition_question type is short answer" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end

      context "when the condition_question type is long answer" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end

      context "when the condition_question type is single option" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end

      context "when the condition_question type is multiple option" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end

      context "when the condition_question type is sorting" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end
    end

    context "when a question has multiple display conditions" do
      context "when all conditions are mandatory" do
        it "is displayed if all conditions are fulfilled"

        it "is not displayed if one of the conditions is not fulfilled"
      end

      context "when all conditions are non-mandatory" do
        it "is displayed if one of the conditions is fulfilled"

        it "is not displayed if none of the conditions are fulfilled"
      end
    end

    context "when a mandatory question has conditions that have not been fulfilled" do
    end
  end
end
