# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Question do
      subject { question }

      let(:questionnaire) { create(:questionnaire) }
      let(:question_type) { "short_answer" }
      let(:question) { build(:questionnaire_question, questionnaire: questionnaire, question_type: question_type) }
      let(:display_conditions) { create_list(:display_condition, 2, question: question) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of display_conditions" do
        expect(subject.display_conditions).to contain_exactly(*display_conditions)
      end

      context "when there are answer_options belonging to this question" do
        let(:answer_options) { create_list(:answer_option, 3, question: question) }

        it "has an association of answer_options" do
          expect(subject.answer_options).to contain_exactly(*answer_options)
        end
      end

      context "when there are matrix_rows belonging to this question" do
        let(:matrix_rows) { create_list(:question_matrix_row, 3, question: question) }

        it "has an association of matrix_rows" do
          expect(subject.matrix_rows).to contain_exactly(*matrix_rows)
        end
      end

      context "when question type doesn't exists in allowed types" do
        let(:question_type) { "foo" }

        it { is_expected.not_to be_valid }
      end

      describe "scopes" do
        let(:question_not_conditioned) { create(:questionnaire_question, questionnaire: questionnaire) }
        let(:question_conditioned) { create(:questionnaire_question, :conditioned, questionnaire: questionnaire) }

        describe "#conditioned" do
          it "includes questions that have display conditions" do
            expect(subject.class.conditioned).to contain_exactly(question_conditioned)
          end

          it "doesn't include questions without display conditions" do
            expect(subject.class.conditioned).not_to include(question_not_conditioned)
          end
        end

        describe "#not_conditioned" do
          it "includes questions that don't have display conditions" do
            expect(subject.class.not_conditioned).to contain_exactly(question_not_conditioned)
          end

          it "doesn't include questions that have display conditions" do
            expect(subject.class.not_conditioned).not_to include(question_conditioned)
          end
        end
      end
    end
  end
end
