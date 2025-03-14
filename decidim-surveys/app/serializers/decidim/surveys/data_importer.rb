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
      # It imports the whole tree of Survey->Questionnaire->questions->response_options.
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
        serialized_questions.each do |serialized_question|
          serialized_response_options = serialized_question.delete(:response_options)
          question = questionnaire.questions.create!(serialized_question.except(:id, :created_at, :updated_at))
          serialized_response_options.each do |serialized_response_option|
            question.response_options.create!(serialized_response_option.except(:id, :created_at, :updated_at))
          end
        end
      end
    end
  end
end
