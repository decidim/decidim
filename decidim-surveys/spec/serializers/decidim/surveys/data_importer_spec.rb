# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe DataImporter do
    describe "#import" do
      subject do
        described_class.new(component).import(as_json, user)
      end

      let(:user) { create(:user) }
      let!(:original_questionnaire) { create(:questionnaire, :with_questions) }
      let!(:survey) { create(:survey, questionnaire: original_questionnaire) }
      let(:component) { survey.component }
      let!(:matrix_question) do
        create(:questionnaire_question, :with_response_options,
               question_type: "matrix_single",
               position: 3,
               questionnaire: original_questionnaire)
      end
      let!(:matrix_rows) do
        [0, 1].map { |position| create(:question_matrix_row, question: matrix_question, position:) }
      end
      let(:condition_question) { original_questionnaire.questions.order(:position).third }
      let!(:display_condition) do
        create(:display_condition, :equal,
               question: matrix_question,
               condition_question:,
               response_option: condition_question.response_options.first)
      end

      let(:as_json) do
        questionnaire_attrs = original_questionnaire.attributes
        questions = []
        original_questionnaire.questions.order(:position).each do |q|
          question_attrs = q.reload.attributes
          question_attrs[:response_options] = q.response_options.map(&:attributes)
          question_attrs[:matrix_rows] = q.matrix_rows.map(&:attributes)
          question_attrs[:display_conditions] = q.display_conditions.map(&:attributes)
          questions << question_attrs
        end
        questionnaire_attrs[:questions] = questions
        [{
          id: rand(99_999),
          questionnaire: questionnaire_attrs
        }]
      end

      context "when the serialized data comes from an export without matrix rows and display conditions" do
        let(:as_json) do
          super().each do |serialized_survey|
            serialized_survey[:questionnaire][:questions].each do |serialized_question|
              serialized_question.delete(:matrix_rows)
              serialized_question.delete(:display_conditions)
            end
          end
        end

        it "imports the survey questions" do
          questions = subject.first.questionnaire.questions
          expect(questions.size).to eq(4)
          expect(questions.flat_map(&:response_options).size).to eq(6)
        end
      end

      describe "#import" do
        let!(:imported) { subject }

        it "imports survey" do
          expect(imported.size).to eq(1)
          imported_survey = imported.first
          expect(imported_survey).to be_a(Decidim::Surveys::Survey)
          expect(imported_survey).to be_persisted
          questionnaire = imported_survey.questionnaire
          expect(questionnaire).to be_a(Decidim::Forms::Questionnaire)

          attribs_to_ignore = %w(id updated_at created_at questionnaire_for_id published_at)
          expected_attrs = original_questionnaire.attributes.except(*attribs_to_ignore)
          actual_attrs = questionnaire.attributes.except(*attribs_to_ignore)
          expect(actual_attrs.delete("published_at")).to be_nil
          expect(actual_attrs).to eq(expected_attrs)

          imported_questions_should_eq_serialized(questionnaire.questions)
        end
      end

      private

      def imported_questions_should_eq_serialized(imported_questions)
        original_questions = original_questionnaire.questions.reload
        expect(imported_questions.size).to eq(original_questions.size)

        imported_questions.zip(original_questions).each do |imported, original|
          expect(imported.position).to eq(original.position)
          expect(imported.question_type).to eq(original.question_type)
          expect(imported.mandatory).to eq(original.mandatory)
          expect(imported.body).to eq(original.body)
          expect(imported.description).to eq(original.description)
          expect(imported.max_choices).to eq(original.max_choices)
          imported_question_options_should_eq_serialized(imported.response_options, original.response_options)
          imported_question_matrix_rows_should_eq_serialized(imported.matrix_rows, original.matrix_rows)
          imported_question_counters_should_be_consistent(imported)
        end

        imported_display_conditions_should_eq_serialized(imported_questions)
      end

      def imported_question_options_should_eq_serialized(imported_response_options, original_response_options)
        expect(imported_response_options.size).to eq(original_response_options.size)
        imported_response_options.zip(original_response_options).each do |imported, original|
          expect(imported.body).to eq(original.body)
          expect(imported.free_text).to eq(original.free_text)
        end
      end

      def imported_question_matrix_rows_should_eq_serialized(imported_matrix_rows, original_matrix_rows)
        expect(imported_matrix_rows.size).to eq(original_matrix_rows.size)
        imported_matrix_rows.zip(original_matrix_rows).each do |imported, original|
          expect(imported.body).to eq(original.body)
          expect(imported.position).to eq(original.position)
        end
      end

      # The display condition of the imported question must point to the
      # imported copies of the condition question and response option, not to
      # the original records.
      def imported_display_conditions_should_eq_serialized(imported_questions)
        imported_matrix_question = imported_questions.detect { |question| question.question_type == "matrix_single" }
        imported_condition_question = imported_questions.detect { |question| question.position == condition_question.position }

        expect(imported_matrix_question.display_conditions.size).to eq(1)
        imported_condition = imported_matrix_question.display_conditions.first
        expect(imported_condition.condition_type).to eq(display_condition.condition_type)
        expect(imported_condition.mandatory).to eq(display_condition.mandatory)
        expect(imported_condition.condition_question).to eq(imported_condition_question)
        expect(imported_condition.condition_question).not_to eq(condition_question)
        expect(imported_condition.response_option).to eq(imported_condition_question.response_options.first)
        expect(imported_condition.response_option).not_to eq(display_condition.response_option)
      end

      def imported_question_counters_should_be_consistent(imported_question)
        imported_question.reload
        expect(imported_question.response_options_count).to eq(imported_question.response_options.count)
        expect(imported_question.matrix_rows_count).to eq(imported_question.matrix_rows.count)
        expect(imported_question.display_conditions_count).to eq(imported_question.display_conditions.count)
        expect(imported_question.display_conditions_for_other_questions_count).to eq(imported_question.display_conditions_for_other_questions.count)
      end
    end
  end
end
