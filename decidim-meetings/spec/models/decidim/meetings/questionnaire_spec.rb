# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Questionnaire do
      subject { questionnaire }

      let!(:questionable) { create(:poll) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: questionable) }

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:meetings_poll_question)
        subject.questions << create(:meetings_poll_question)
        expect(subject.questions.count).to eq(2)
      end

      it "has an association of responses" do
        create(:meetings_poll_response, questionnaire: subject, user: create(:user, organization: questionable.organization))
        create(:meetings_poll_response, questionnaire: subject, user: create(:user, organization: questionable.organization))
        expect(subject.reload.responses.count).to eq(2)
      end

      context "without a questionable" do
        let(:questionnaire) { build(:meetings_poll_questionnaire, questionnaire_for: nil) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionable" do
        expect(questionnaire.questionnaire_for).to eq(questionable)
      end

      describe "#all_questions_unpublished?" do
        it "returns true when all questionnaire questions are in unpublished state" do
          subject.questions << create(:meetings_poll_question, :unpublished)
          subject.questions << create(:meetings_poll_question, :unpublished)

          expect(subject).to be_all_questions_unpublished
        end

        it "returns false when any questionnaire question is not unpublished" do
          subject.questions << create(:meetings_poll_question, :unpublished)
          subject.questions << create(:meetings_poll_question, :published)

          expect(subject).not_to be_all_questions_unpublished
        end
      end
    end
  end
end
