# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe DisplayCondition do
      subject { display_condition }

      let(:questionnaire) { create(:questionnaire) }
      let(:condition_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 2) }
      let(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 3) }
      let(:condition_type) { :answered }
      let(:display_condition) do
        build(
          :display_condition,
          question: question,
          condition_question: condition_question,
          condition_type: condition_type
        )
      end

      let(:question_condition_equal) do
        build(
          :display_condition,
          :equal,
          question: question,
          condition_question: condition_question,
          answer_option: answer_option
        )
      end

      let(:answer) { create(:answer, question: condition_question, questionnaire: questionnaire) }
      let(:answer_option) { create(:answer_option, question: condition_question) }

      describe "associations" do
        it "has a question association" do
          expect(subject.question).to eq(question)
        end

        it "has a condition_question association" do
          expect(subject.condition_question).to eq(condition_question)
        end

        context "when condition_type is :equal" do
          let(:display_condition) { question_condition_equal }
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
          let(:display_condition) { question_condition_equal }
          let(:answer_choice) { create(:answer_choice, answer: answer) }
          let(:answer_option) { answer_choice.answer_option }

          it "is fulfilled if the answer choices include answer_option" do
            expect(subject.fulfilled?(answer)).to be true
          end
        end

        context "when condition_type is :match" do
          let(:condition_type) { :match }
          let(:display_condition) do
            build(:display_condition,
                  :match,
                  question: question,
                  condition_question: condition_question,
                  answer_option: answer_option,
                  condition_value: { en: "Yes", es: "Sí", ca: "Sí" })
          end

          let(:match_text) { display_condition.condition_value["en"].downcase }
          let(:answer_matched) { create(:answer, body: "Fulfill #{match_text}. Yay!") }
          let(:answer_unmatched) { create(:answer, body: "Hi! I won't fulfill the condition.") }

          it "is fulfilled if the answer body matches the given value" do
            expect(subject.fulfilled?(answer_matched)).to be true
          end

          it "is not fulfilled if the answer body doesn't match the given value" do
            expect(subject.fulfilled?(answer_unmatched)).to be false
          end
        end
      end
    end
  end
end
