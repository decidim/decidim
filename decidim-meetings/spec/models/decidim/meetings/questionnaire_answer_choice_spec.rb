# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe QuestionnaireAnswerChoice do
      subject { questionnaire_answer_choice }

      let(:questionnaire) { create(:questionnaire) }
      let(:question) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:answer) { build(:questionnaire_answer, questionnaire: questionnaire, question: question) }
      let(:answer_option) { build(:questionnaire_answer_option, question: question) }
      let(:questionnaire_answer_choice) { build(:questionnaire_answer_choice, answer: answer, answer_option: answer_option) }

      it { is_expected.to be_valid }

      it "has an association of answer" do
        expect(subject.answer).to eq(answer)
      end

      context "when answer doesn't exists" do
        let(:answer) { nil }

        it { is_expected.not_to be_valid }
      end

      it "has an association of answer_option" do
        expect(subject.answer_option).to eq(answer_option)
      end

      context "when answer_option doesn't exists" do
        let(:answer_option) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
