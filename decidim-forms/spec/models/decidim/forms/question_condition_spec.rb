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

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end
      
      it "has an association of condition_question" do
        expect(subject.condition_question).to eq(condition_question)
      end

      context "when condition type doesn't exists in allowed types" do
        let(:condition_type) { :foo }

        it { is_expected.not_to be_valid }
      end

      context "when condition_question is positioned before question" do
        before do
          question.position = condition_question.position - 1
        end
        
        it { is_expected.not_to be_valid }
      end
    end
  end
end
