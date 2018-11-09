# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Answer do
      subject { answer }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:answer) { create(:answer, questionnaire: questionnaire, question: question, user: user) }

      it { is_expected.to be_valid }

      it "requires choices for mandatory multiple choice questions" do
        answer.question.update!(question_type: "single_option", mandatory: true)
        answer.choices = []
        expect(subject).not_to be_valid
      end

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of question" do
        expect(subject.question).to eq(question)
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
        let(:question) { create(:questionnaire_question, questionnaire: questionnaire, mandatory: true) }

        it "is not valid with an empty body" do
          subject.body = ""
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
