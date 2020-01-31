# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionCondition do
      subject { question_condition }

      let(:questionnaire) { create(:questionnaire) }
      let(:condition_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }
      let(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 3) }
      let(:condition_type) { :answered }
      let(:question_condition) do
        build(
          :question_condition,
          question: question,
          condition_question: condition_question,
          condition_type: condition_type
        )
      end

      it { is_expected.to be_valid }

      context "when condition_question is positioned before question" do
        before do
          question.position = condition_question.position - 1
        end

        it { is_expected.not_to be_valid }
      end

      it "has a question association" do
        expect(subject.question).to eq(question)
      end

      it "has a condition_question association" do
        expect(subject.condition_question).to eq(condition_question)
      end

      context "when condition_type is :equal" do
        let(:answer_option) { create(:answer_option, question: condition_question) }
        let(:question_condition) do
          create(
            :question_condition,
            :equal,
            question: question,
            condition_question: condition_question,
            answer_option: answer_option
          )
        end

        it "has an answer_option association" do
          expect(subject.answer_option).to eq(answer_option)
        end
      end
    end
  end
end
