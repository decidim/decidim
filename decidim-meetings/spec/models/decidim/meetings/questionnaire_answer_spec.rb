# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe QuestionnaireAnswer do
      subject { questionnaire_answer }

      let(:meeting) { create(:meeting) }
      let(:user) { create(:user, organization: meeting.organization) }
      let(:questionnaire) { create(:questionnaire, meeting: meeting) }
      let(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:questionnaire_answer) { create(:questionnaire_answer, questionnaire: questionnaire, question: questionnaire_question, user: user) }

      it { is_expected.to be_valid }

      it "requires choices for mandatory multiple choice questions" do
        questionnaire_answer.question.update!(question_type: "single_option", mandatory: true)
        questionnaire_answer.choices = []
        expect(subject).not_to be_valid
      end

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of question" do
        expect(subject.question).to eq(questionnaire_question)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      context "when the user doesn't belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end

      context "when question doesn't belong to the questionnaire" do
        it "is not valid" do
          subject.question = create(:questionnaire_question)
          expect(subject).not_to be_valid
        end
      end

      context "when question is mandatory" do
        let(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, mandatory: true) }

        it "is not valid with an empty body" do
          subject.body = ""
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
