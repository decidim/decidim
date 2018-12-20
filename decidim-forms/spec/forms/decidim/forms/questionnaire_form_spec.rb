# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionnaireForm do
      subject do
        described_class.from_model(questionnaire)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }

      it "builds empty answers for each question" do
        expect(subject.answers.length).to eq(1)
      end

      context "when tos_agreement is not accepted" do
        it { is_expected.not_to be_valid }
      end

      context "when tos_agreement is not accepted" do
        before do
          subject.tos_agreement = true
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
