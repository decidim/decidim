# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe AnswerOption do
      subject { answer_option }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question_type) { "single_option" }
      let(:question) { create(:questionnaire_question, questionnaire:, question_type:) }
      let(:display_conditions) { create_list(:display_condition, 2, answer_option:) }
      let(:answer_option) { build(:answer_option, question:, body: { en: "A statement", ca: "Una afirmació", es: "Una afirmación" }) }

      it { is_expected.to be_valid }

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has an association of display_conditions" do
        expect(subject.display_conditions).to eq(display_conditions)
      end

      describe "#translated_body" do
        it "returns the translated body of the answer option" do
          expect(subject.translated_body).to eq(subject.body["en"])
        end
      end
    end
  end
end
