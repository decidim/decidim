# frozen_string_literal: true

module Decidim
  module Surveys
    # A class used to collect user responses for a questionnaire
    class QuestionnaireUserResponses < Decidim::Query
      def self.for(questionnaire)
        new(questionnaire).query
      end

      # Initializes the class.
      #
      # questionnaire = a Questionnaire object
      def initialize(questionnaire)
        @questionnaire = questionnaire
      end

      # Returns grouped user responses for published surveys only
      def query
        Decidim::Forms::Response
          .joins(:question)
          .where(questionnaire: @questionnaire)
          .where.not(decidim_forms_questions: { question_type: %w(separator title_and_description) })
      end
    end
  end
end
