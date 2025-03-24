# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Question do
      subject { question }

      let(:questionnaire) { create(:questionnaire) }
      let(:question_type) { "short_response" }
      let(:question) { build(:questionnaire_question, questionnaire:, question_type:) }
      let(:display_conditions) { create_list(:display_condition, 2, question:) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of display_conditions" do
        expect(subject.display_conditions).to match_array(display_conditions)
      end

      context "when there are response_options belonging to this question" do
        let(:response_options) { create_list(:response_option, 3, question:) }

        it "has an association of response_options" do
          expect(subject.response_options).to match_array(response_options)
        end
      end

      context "when there are matrix_rows belonging to this question" do
        let(:matrix_rows) { create_list(:question_matrix_row, 3, question:) }

        it "has an association of matrix_rows" do
          expect(subject.matrix_rows).to match_array(matrix_rows)
        end
      end

      context "when question type does not exists in allowed types" do
        let(:question_type) { "foo" }

        it { is_expected.not_to be_valid }
      end

      describe "scopes" do
        let(:question_not_conditioned) { create(:questionnaire_question, questionnaire:) }
        let(:question_conditioned) { create(:questionnaire_question, :conditioned, questionnaire:) }

        describe "#conditioned" do
          it "includes questions that have display conditions" do
            expect(subject.class.conditioned).to contain_exactly(question_conditioned)
          end

          it "does not include questions without display conditions" do
            expect(subject.class.conditioned).not_to include(question_not_conditioned)
          end
        end

        describe "#not_conditioned" do
          it "includes questions that do not have display conditions" do
            expect(subject.class.not_conditioned).to contain_exactly(question_not_conditioned)
          end

          it "does not include questions that have display conditions" do
            expect(subject.class.not_conditioned).not_to include(question_conditioned)
          end
        end
      end

      describe ".log_presenter_class_for" do
        it "returns the correct presenter class for logs" do
          expect(described_class.log_presenter_class_for(nil)).to eq(Decidim::Forms::AdminLog::QuestionPresenter)
        end
      end
    end
  end
end
