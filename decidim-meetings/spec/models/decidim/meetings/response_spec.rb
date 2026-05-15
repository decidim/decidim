# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Response do
      subject { response }

      let(:meeting) { create(:meeting) }
      let(:user) { create(:user, organization: meeting.organization) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: meeting) }
      let(:question) { create(:meetings_poll_question, questionnaire:) }
      let(:response) { create(:meetings_poll_response, questionnaire:, question:, user:) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      context "when the user does not belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end

      context "when question does not belong to the questionnaire" do
        it "is not valid" do
          subject.question = create(:meetings_poll_question)
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
