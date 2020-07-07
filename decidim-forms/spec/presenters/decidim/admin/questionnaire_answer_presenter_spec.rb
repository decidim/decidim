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

        it "Returns the answer body" do
          expect(subject.body).to eq(answer.body)
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
