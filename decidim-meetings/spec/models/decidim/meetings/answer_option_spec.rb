# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe AnswerOption do
      subject { answer_option }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:meeting) { create(:meeting) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: meeting) }
      let(:question_type) { "single_option" }
      let(:question) { create(:meetings_poll_question, questionnaire:, question_type:) }
      let(:answer_option) { build(:meetings_poll_answer_option, question:, body: { en: "A statement", ca: "Una afirmació", es: "Una afirmación" }) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      describe "#translated_body" do
        it "returns the translated body of the answer option" do
          expect(subject.translated_body).to eq(subject.body["en"])
        end
      end
    end
  end
end
