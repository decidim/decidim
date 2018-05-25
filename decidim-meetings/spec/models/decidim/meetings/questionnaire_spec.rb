# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Questionnaire do
      subject { questionnaire }

      let(:questionnaire) { create(:questionnaire) }
      let(:organization) { questionnaire.meeting.component.organization }

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:questionnaire_question)
        subject.questions << create(:questionnaire_question)
        expect(subject.questions.count).to eq(2)
      end

      it "has an association of answers" do
        create(:questionnaire_answer, questionnaire: subject, user: create(:user, organization: organization))
        create(:questionnaire_answer, questionnaire: subject, user: create(:user, organization: organization))
        expect(subject.reload.answers.count).to eq(2)
      end

      context "without a meeting" do
        let(:questionnaire) { build :questionnaire, meeting: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated meeting" do
        expect(questionnaire.meeting).to be_a(Decidim::Meetings::Meeting)
      end

      describe "#questions_editable?" do
        it "returns false when questionnaire has already answers" do
          create(:questionnaire_answer, questionnaire: questionnaire)
          expect(subject.reload).not_to be_questions_editable
        end
      end

      describe "#answered_by?" do
        let!(:user) { create(:user, organization: organization) }
        let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }

        it "returns false if the given user has not answered the questionnaire" do
          expect(questionnaire).not_to be_answered_by(user)
        end

        it "returns true if the given user has answered the questionnaire" do
          create(:questionnaire_answer, questionnaire: questionnaire, question: question, user: user)
          expect(questionnaire).to be_answered_by(user)
        end
      end
    end
  end
end
