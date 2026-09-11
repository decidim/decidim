# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe DataSerializer do
    describe "#serialize" do
      subject do
        described_class.new(survey.component)
      end

      let!(:questionnaire) { build(:questionnaire, :with_questions) }
      let!(:survey) { create(:survey, questionnaire:) }
      let!(:matrix_question) do
        create(:questionnaire_question, :with_response_options,
               question_type: "matrix_single",
               position: 3,
               questionnaire:)
      end
      let!(:matrix_rows) do
        [0, 1].map { |position| create(:question_matrix_row, question: matrix_question, position:) }
      end
      let(:condition_question) { questionnaire.questions.order(:position).third }
      let!(:display_condition) do
        create(:display_condition, :equal,
               question: matrix_question,
               condition_question:,
               response_option: condition_question.response_options.first)
      end

      let(:serialized_surveys) { subject.serialize }

      it "serializes questionnaire" do
        expect(serialized_surveys.count).to eq(1)
        serialized_survey = serialized_surveys.first
        expect(serialized_survey[:id]).to eq(survey.id)

        serialized_questionnaire = serialized_survey[:questionnaire]
        expect(serialized_questionnaire[:title]).to eq(questionnaire.title)
        expect(serialized_questionnaire[:description]).to eq(questionnaire.description)
        expect(serialized_questionnaire[:tos]).to eq(questionnaire.tos)
        expect(serialized_questionnaire[:questionnaire_for_type]).to eq(survey.class.name)
        expect(serialized_questionnaire[:questionnaire_for_id]).to eq(survey.id)
        expect(serialized_questionnaire[:published_at]).to eq(questionnaire.published_at)

        questions_should_be_as_expected(questionnaire.questions.order(:position), serialized_questionnaire[:questions])
      end

      def questions_should_be_as_expected(questions, serializeds)
        expect(serializeds.size).to eq(4)
        num_expected_responses_list = [0, 0, 3, 3]
        serializeds.zip(questions, num_expected_responses_list) do |serialized, question, num_expected_responses|
          expect(serialized[:id]).to eq(question.id)
          expect(serialized[:decidim_questionnaire_id]).to eq(question.decidim_questionnaire_id)
          expect(serialized[:position]).to eq(question.position)
          expect(serialized[:question_type]).to eq(question.question_type)
          expect(serialized[:mandatory]).to eq(question.mandatory)
          expect(serialized[:body]).to eq(question.body)
          expect(serialized[:description]).to eq(question.description)
          expect(serialized[:max_choices]).to eq(question.max_choices)

          options_should_be_as_expected(question.response_options.order(:id), serialized[:response_options], num_expected_responses)
          matrix_rows_should_be_as_expected(question.matrix_rows, serialized[:matrix_rows])
          display_conditions_should_be_as_expected(question.display_conditions, serialized[:display_conditions])
        end
      end

      def options_should_be_as_expected(response_options, serializeds, num_expected)
        expect(serializeds.size).to eq(num_expected)
        serializeds.zip(response_options) do |serialized, option|
          expect(serialized[:id]).to eq(option.id)
          expect(serialized[:decidim_question_id]).to eq(option.decidim_question_id)
          expect(serialized[:body]).to eq(option.body)
          expect(serialized[:free_text]).to eq(option.free_text)
        end
      end

      def matrix_rows_should_be_as_expected(matrix_rows, serializeds)
        expect(serializeds.size).to eq(matrix_rows.size)
        serializeds.zip(matrix_rows) do |serialized, matrix_row|
          expect(serialized[:id]).to eq(matrix_row.id)
          expect(serialized[:decidim_question_id]).to eq(matrix_row.decidim_question_id)
          expect(serialized[:body]).to eq(matrix_row.body)
          expect(serialized[:position]).to eq(matrix_row.position)
        end
      end

      def display_conditions_should_be_as_expected(display_conditions, serializeds)
        expect(serializeds.size).to eq(display_conditions.size)
        serializeds.zip(display_conditions) do |serialized, display_condition|
          expect(serialized[:id]).to eq(display_condition.id)
          expect(serialized[:decidim_question_id]).to eq(display_condition.decidim_question_id)
          expect(serialized[:decidim_condition_question_id]).to eq(display_condition.decidim_condition_question_id)
          expect(serialized[:decidim_response_option_id]).to eq(display_condition.decidim_response_option_id)
          expect(serialized[:condition_type]).to eq(display_condition.condition_type)
          expect(serialized[:condition_value]).to eq(display_condition.condition_value)
          expect(serialized[:mandatory]).to eq(display_condition.mandatory)
        end
      end
    end
  end
end
