# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe AnswerChoice do
      subject { answer_choice }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:meeting) { create(:meeting) }
      let(:poll) { create(:poll, meeting:) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
      let(:question_type) { "single_option" }
      let(:question) { create(:meetings_poll_question, questionnaire:, question_type:) }
      let(:answer_options) { create_list(:meetings_poll_answer_option, 3, question:) }
      let(:answer_option) { answer_options.first }
      let(:answer) { create(:meetings_poll_answer, question:, questionnaire:) }
      let(:answer_choice) { build(:meetings_poll_answer_choice, answer:, answer_option:) }

      it { is_expected.to be_valid }

      it "has an association of answer" do
        expect(subject.answer).to eq(answer)
      end

      it "has an association of answer_option" do
        expect(subject.answer_option).to eq(answer_option)
      end
    end
  end
end
