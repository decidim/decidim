# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Questionnaire do
      subject { questionnaire }

      let!(:questionable) { create(:dummy_resource) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:question)
        subject.questions << create(:question)
        expect(subject.questions.count).to eq(2)
      end

      it "has an association of answers" do
        create(:answer, questionnaire: subject, user: create(:user, organization: questionable.organization))
        create(:answer, questionnaire: subject, user: create(:user, organization: questionable.organization))
        expect(subject.reload.answers.count).to eq(2)
      end

      context "without a questionable" do
        let(:questionnaire) { build :questionnaire, questionnaire_for: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionable" do
        expect(questionnaire.questionnaire_for).to eq(questionable)
      end

      describe "#questions_editable?" do
        it "returns false when questionnaire has already answers" do
          create(:answer, questionnaire: questionnaire)
          expect(subject.reload).not_to be_questions_editable
        end
      end

      describe "#answered_by?" do
        let!(:user) { create(:user, organization: questionnaire.questionnaire_for.component.participatory_space.organization) }
        let!(:question) { create(:question, questionnaire: questionnaire) }

        it "returns false if the given user has not answered the questionnaire" do
          expect(questionnaire).not_to be_answered_by(user)
        end

        it "returns true if the given user has answered the questionnaire" do
          create(:answer, questionnaire: questionnaire, question: question, user: user)
          expect(questionnaire).to be_answered_by(user)
        end
      end
    end
  end
end
