# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionnaireForm do
      subject do
        described_class.from_model(questionnaire).with_context(context)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:question) { create(:questionnaire_question, questionnaire:) }
      let(:current_user) { create(:user) }
      let(:session_token) { "some-token" }
      let(:context) do
        {
          session_token:
        }
      end

      it "builds empty answers for each question" do
        expect(subject.responses.length).to eq(1)
      end

      context "when tos_agreement is not accepted" do
        it { is_expected.not_to be_valid }
      end

      context "when tos_agreement is accepted" do
        before do
          subject.tos_agreement = true
        end

        context "and no token is present" do
          let(:session_token) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and token is present" do
          let(:ip_hash) { nil }

          it { is_expected.to be_valid }
        end
      end

      describe "responses_by_step" do
        let!(:separator) { create(:questionnaire_question, questionnaire:, position: 1, question_type: :separator) }
        let!(:question2) { create(:questionnaire_question, questionnaire:, position: 2) }

        it "groups responses by their step" do
          result = subject.responses_by_step.map { |step| step.map(&:question_id) }

          expect(result).to eq(
            [
              [question.id.to_s, separator.id.to_s],
              [question2.id.to_s]
            ]
          )
        end

        context "with no questions" do
          before do
            questionnaire.questions.delete_all
          end

          it "returns an empty spec" do
            result = subject.responses_by_step

            expect(result).to eq([[]])
          end
        end
      end

      describe "total_steps" do
        let!(:separator) { create(:questionnaire_question, questionnaire:, position: 1, question_type: :separator) }
        let!(:question2) { create(:questionnaire_question, questionnaire:, position: 2) }

        it "counts the total steps" do
          expect(subject.total_steps).to eq 2
        end
      end
    end
  end
end
