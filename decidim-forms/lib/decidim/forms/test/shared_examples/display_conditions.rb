# frozen_string_literal: true

shared_examples_for "display conditions" do
  before do
    login_as user, scope: :user
  end

  context "when a question has a display condition" do
    context "when condition is of type 'answered'" do
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }
      let!(:display_condition) { create(:display_condition, condition_type: "answered", question: question, condition_question: condition_question) }
      let!(:answer_options) { 3.times.to_a.map { |x| { "body" => Hash[[:en, :es, :ca].map { |key| [key, "Body #{x}"] }] } } }

      before do
        visit questionnaire_public_path
      end

      context "when the condition_question type is short answer" do
        let!(:condition_question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "short_answer", position: 1) }

        it "does not show the question if the condition is not fulfilled" do
          expect(page).to have_css("#questionnaire_answers_1", visible: false)
        end

        it "shows the question if the condition is fulfilled" do
          fill_in "questionnaire_answers_0", with: "Cacatua"
          check "questionnaire_tos_agreement"

          expect(page).to have_css("#questionnaire_answers_1", visible: true)
        end
      end

      context "when the condition_question type is long answer" do
        let!(:condition_question) { create(:questionnaire_question, questionnaire: questionnaire, question_type: "long_answer", position: 1) }

        it "does not show the question if the condition is not fulfilled" do
          expect(page).to have_css("#questionnaire_answers_1", visible: false)
        end

        it "shows the question if the condition is fulfilled" do
          fill_in "questionnaire_answers_0", with: "Cacatua"
          check "questionnaire_tos_agreement"

          expect(page).to have_css("#questionnaire_answers_1", visible: true)
        end
      end

      context "when the condition_question type is single option" do
        let!(:condition_question) do
          create(:questionnaire_question, questionnaire: questionnaire, question_type: "single_option", position: 1, options: answer_options)
        end

        it "does not show the question if the condition is not fulfilled" do
          expect(page).to have_css("#questionnaire_answers_1", visible: false)
        end

        it "shows the question if the condition is fulfilled" do
          choose condition_question.answer_options.first.body["en"]
          check "questionnaire_tos_agreement"

          expect(page).to have_css("#questionnaire_answers_1", visible: true)
        end
      end

      context "when the condition_question type is multiple option" do
        let!(:condition_question) do
          create(:questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option", position: 1, options: answer_options)
        end

        it "does not show the question if the condition is not fulfilled" do
          expect(page).to have_css("#questionnaire_answers_1", visible: false)
        end

        it "shows the question if the condition is fulfilled" do
          check condition_question.answer_options.first.body["en"]
          check "questionnaire_tos_agreement"

          expect(page).to have_css("#questionnaire_answers_1", visible: true)
        end
      end

      context "when the condition_question type is sorting" do
        it "shows the question if the condition is fulfilled"
        it "does not show the question if the condition is not fulfilled"
      end
    end

    context "when a question has a display condition of type 'not_answered'" do
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

    context "when a question has a display condition of type 'equal'" do
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

    context "when a question has a display condition of type 'not_equal'" do
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
