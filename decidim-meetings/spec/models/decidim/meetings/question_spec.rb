# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Question do
      subject { question }

      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: meeting_component.organization) }
      let(:meeting_component) { create(:meeting_component) }
      let(:meeting) { create(:meeting, component: meeting_component) }
      let(:poll) { create(:poll, meeting:) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
      let(:question) { create(:meetings_poll_question, questionnaire:) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      describe "#responded_by?" do
        it "returns false if user has not responded the question" do
          expect(subject.responded_by?(current_user)).to be(false)
        end

        it "returns true if user has responded the question" do
          create(:meetings_poll_response, question:, user: current_user, questionnaire:)
          expect(subject.responded_by?(current_user)).to be(true)
        end
      end

      describe "#responses_count" do
        it "returns zero if there are no responses" do
          expect(subject.responses_count).to be(0)
        end

        it "returns the number of responses" do
          create(:meetings_poll_response, question:, user: current_user, questionnaire:)
          expect(subject.responses_count).to be(1)
        end
      end

      context "when question type does not exists in allowed types" do
        let(:question) { build(:meetings_poll_question, questionnaire:, question_type: "foo") }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
