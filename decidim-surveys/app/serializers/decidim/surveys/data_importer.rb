# frozen_string_literal: true

module Decidim
  module Surveys
    # Importer for Surveys specific data (this is, its questionnaire).
    class DataImporter < Decidim::Importers::Importer
      def initialize(component)
        @component = component
      end

      # Public: Creates a new Decidim::Surveys::Survey and Decidim::Forms::Questionnaire associated to the given +component+
      #         for each serialized survey object.
      # It imports the whole tree of Survey->Questionnaire->questions with their
      # response_options, matrix_rows and display_conditions.
      #
      # serialized        - The Hash of attributes for the Questionnaire and its relations.
      # user              - The +user+ that is performing this action
      #
      # Returns the ser.
      def import(serialized, user)
        ActiveRecord::Base.transaction do
          # we duplicate so that we can delete without affecting the received Hash
          serialized.dup.collect do |serialized_survey|
            import_survey(serialized_survey, user)
          end
        end
      end

      private

      # Returns a persisted Survey instance build from +serialized_survey+.
      def import_survey(serialized_survey, user)
        serialized_survey = serialized_survey.with_indifferent_access
        survey = build_survey(serialized_survey)
        serialized_questionnaire = serialized_survey[:questionnaire]
        serialized_questions = serialized_questionnaire.delete(:questions)

        questionnaire = build_questionnaire(survey, serialized_questionnaire)
        Decidim.traceability.perform_action!(:create, Decidim::Surveys::Survey, user) do
          survey.save!
          survey
        end
        import_questions(questionnaire, serialized_questions)
        survey
      end

      def build_survey(_serialized)
        Survey.new(component: @component)
      end

      # Builds a Decidim::Forms::Questionnaire with all its questions and response_options.
      def build_questionnaire(survey, serialized_questionnaire)
        survey.build_questionnaire(serialized_questionnaire.except(:id, :published_at))
      end

      def import_questions(questionnaire, serialized_questions)
        questions_by_original_id = {}
        response_options_by_original_id = {}
        pending_display_conditions = []

        serialized_questions.each do |serialized_question|
          serialized_response_options = serialized_question.delete(:response_options) || []
          serialized_matrix_rows = serialized_question.delete(:matrix_rows) || []
          pending_serialized_conditions = serialized_question.delete(:display_conditions) || []

          question = questionnaire.questions.create!(question_attributes(serialized_question))
          questions_by_original_id[serialized_question[:id]] = question
          pending_display_conditions << [question, pending_serialized_conditions]

          serialized_response_options.each do |serialized_response_option|
            response_option = question.response_options.create!(serialized_response_option.except(:id, :created_at, :updated_at))
            response_options_by_original_id[serialized_response_option[:id]] = response_option
          end

          serialized_matrix_rows.each do |serialized_matrix_row|
            question.matrix_rows.create!(serialized_matrix_row.except(:id, :created_at, :updated_at))
          end
        end

        pending_display_conditions.each do |question, serialized_conditions|
          serialized_conditions.each do |serialized_condition|
            import_display_condition(question, serialized_condition, questions_by_original_id, response_options_by_original_id)
          end
        end
      end

      def import_display_condition(question, serialized_condition, questions_by_original_id, response_options_by_original_id)
        question.display_conditions.create!(
          serialized_condition.except(
            :id, :created_at, :updated_at,
            :decidim_question_id, :decidim_condition_question_id, :decidim_response_option_id
          ).merge(
            condition_question: questions_by_original_id.fetch(serialized_condition[:decidim_condition_question_id]),
            response_option: serialized_condition[:decidim_response_option_id] &&
              response_options_by_original_id.fetch(serialized_condition[:decidim_response_option_id])
          )
        )
      end

      def question_attributes(serialized_question)
        serialized_question.except(
          :id, :created_at, :updated_at,
          :response_options_count, :matrix_rows_count,
          :display_conditions_count, :display_conditions_for_other_questions_count
        )
      end
    end
  end
end
