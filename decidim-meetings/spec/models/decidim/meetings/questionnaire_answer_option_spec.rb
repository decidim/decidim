# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe QuestionnaireAnswerOption do
      subject { questionnaire_answer_option }

      let(:question) { create(:questionnaire_question) }
      let(:questionnaire_answer_option) { build(:questionnaire_answer_option, question: question) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      context "when question doesn't exists" do
        let(:question) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
