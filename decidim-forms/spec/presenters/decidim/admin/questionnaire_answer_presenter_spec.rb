# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Forms::Admin::QuestionnaireAnswerPresenter, type: :helper do
    subject { described_class.new(answer: answer) }

    let!(:questionnaire) { create :questionnaire }
    let!(:answer) { create(:answer, questionnaire: questionnaire) }

    describe "questionnaire_answer_body" do
      context "when answer has a body" do
        before do
          answer.body = "abc"
        end

        it "Returns the formatted answer body" do
          expect(subject.body).to eq("<p>#{answer.body}</p>")
        end
      end

      context "when answer has no selected choices" do
        let!(:question) { create :questionnaire_question, question_type: "multiple_option" }

        before do
          answer.body = nil
        end

        it "Returns '-'" do
          expect(subject.body).to eq("-")
        end
      end

      context "when answer has one selected choice" do
        let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "single_option" }
        let!(:answer) { create(:answer, questionnaire: questionnaire, question: question, body: nil) }
        let!(:answer_option) { create :answer_option, question: question }
        let!(:answer_choice) { create :answer_choice, answer: answer, answer_option: answer_option, body: translated(answer_option.body, locale: I18n.locale) }

        context "when it is a single_option question" do
          it "Returns the choice's body" do
            expect(subject.body).to eq(answer_choice.body)
          end
        end

        context "when it is a multiple_option question" do
          let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "multiple_option" }

          it "Returns the choice's body as a <li> element inside a <ul>" do
            expect(subject.body).to eq("<ul><li>#{answer_choice.body}</li></ul>")
          end
        end

        context "when it is a matrix_single question" do
          let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "matrix_single" }
          let!(:matrix_row) { create :question_matrix_row, question: question }
          let!(:answer) { create(:answer, questionnaire: questionnaire, question: question, body: nil) }
          let!(:answer_option) { create :answer_option, question: question }
          let!(:answer_choice) { create :answer_choice, answer: answer, answer_option: answer_option, matrix_row: matrix_row, body: translated(answer_option.body, locale: I18n.locale) }

          it "Returns the choice's body as a <dd> element preceded by a <dt> with the matrix row body, both inside a <dl>" do
            expect(subject.body).to eq("<dl><dt>#{translated matrix_row.body}</dt><dd>#{answer_choice.body}</dd></dl>")
          end
        end

        context "when it is a matrix_multiple question" do
          let!(:question) { create :questionnaire_question, questionnaire: questionnaire, question_type: "matrix_multiple" }
          let!(:matrix_rows) { create_list :question_matrix_row, 2, question: question }
          let!(:answer) { create(:answer, questionnaire: questionnaire, question: question, body: nil) }
          let!(:answer_options) { create_list :answer_option, 2, question: question }
          let!(:answer_choice_1) { create :answer_choice, answer: answer, answer_option: answer_options.first, matrix_row: matrix_rows.second }
          let!(:answer_choice_2) { create :answer_choice, answer: answer, answer_option: answer_options.first, matrix_row: matrix_rows.first }
          let!(:answer_choice_3) { create :answer_choice, answer: answer, answer_option: answer_options.second, matrix_row: matrix_rows.first }

          it "Returns the choice's body as <dd> elements preceded by a <dt> with the matrix row body, all inside a <dl>" do
            expect(subject.body).to match "<dl>.*</dl>"
            expect(subject.body).to include "<dt>#{translated matrix_rows.second.body}</dt><dd>#{answer_choice_1.body}</dd>"
            expect(subject.body).to include "<dt>#{translated matrix_rows.first.body}</dt><dd>#{answer_choice_2.body}</dd>"
            expect(subject.body).to include "<dt>#{translated matrix_rows.first.body}</dt><dd>#{answer_choice_3.body}</dd>"
          end
        end
      end

      context "when answer has many selected choices" do
        let!(:answer) { create(:answer, body: nil) }
        let!(:answer_option_1) { create :answer_option, question: answer.question }
        let!(:answer_option_2) { create :answer_option, question: answer.question }
        let!(:answer_choice_1) { create :answer_choice, answer: answer, answer_option: answer_option_1, body: translated(answer_option_1.body, locale: I18n.locale) }
        let!(:answer_choice_2) { create :answer_choice, answer: answer, answer_option: answer_option_2, body: translated(answer_option_2.body, locale: I18n.locale) }

        it "Returns the choices wrapped in <li> elements inside a <ul>" do
          expect(subject.body).to eq("<ul><li>#{answer_choice_1.body}</li><li>#{answer_choice_2.body}</li></ul>")
        end
      end
    end
  end
end
