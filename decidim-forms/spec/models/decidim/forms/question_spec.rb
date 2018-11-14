# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Question do
      subject { question }

      let(:questionnaire) { create(:questionnaire) }
      let(:question_type) { "short_answer" }
      let(:question) { build(:questionnaire_question, questionnaire: questionnaire, question_type: question_type) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      context "when question type doesn't exists in allowed types" do
        let(:question_type) { "foo" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
