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
          condition_type: condition_type)
      end

      let(:question_condition_equal) do
        build(
          :question_condition,
          :equal,
          question: question,
          condition_question: condition_question,
          answer_option: answer_option)
      end

      let(:answer) { create(:answer, question: question, questionnaire: questionnaire) }
      let(:answer_option) { create(:answer_option, question: question) }

      describe "validations" do
        it { is_expected.to be_valid }

        context "when condition_question is positioned before question" do
          before do
            question.position = condition_question.position - 1
          end

          it { is_expected.not_to be_valid }
        end

        context "when answer_option is not from condition_question" do
          let(:question_condition) { question_condition_equal }
          
          before do
            question_condition.answer_option { create(:answer_option)}
          end

          it { is_expected.not_to be_valid }
        end
      end

      describe "associations" do
        it "has a question association" do
          expect(subject.question).to eq(question)
        end

        it "has a condition_question association" do
          expect(subject.condition_question).to eq(condition_question)
        end

        context "when condition_type is :equal" do
          let(:question_condition) { question_condition_equal }
          let(:answer_option) { create(:answer_option, question: condition_question) }

          it "has an answer_option association" do
            expect(subject.answer_option).to eq(answer_option)
          end
        end
      end

      describe "#fulfilled?" do
        context "when condition_type is :answered" do
          let(:condition_type) { :answered }

          it "is fulfilled only if given answer is present" do
            expect(subject.fulfilled?(answer)).to be true
            expect(subject.fulfilled?(nil)).to be false
          end
        end

        context "when condition_type is :not_answered" do
          let(:condition_type) { :not_answered }

          it "is fulfilled only if given answer is not present" do
            expect(subject.fulfilled?(nil)).to be true
            expect(subject.fulfilled?(answer)).to be false
          end
        end

        context "when condition_type is :equal" do
          let(:condition_type) { :equal }
          let(:question_condition) { question_condition_equal }
          let(:answer_choice) { create(:answer_choice, answer: answer) }
          let(:answer_option) { answer_choice.answer_option }

          it "if the answer choices include answer_option" do
            expect(subject.fulfilled?(answer)).to be true
          end
        end
      end
    end
  end
end
