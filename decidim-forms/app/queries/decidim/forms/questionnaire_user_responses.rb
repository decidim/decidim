# frozen_string_literal: true

module Decidim
  module Forms
    # A class used to collect user responses for a questionnaire
    class QuestionnaireUserResponses < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # questionnaire - a Questionnaire object
      def self.for(questionnaire)
        new(questionnaire).query
      end

      # Initializes the class.
      #
      # questionnaire = a Questionnaire object
      def initialize(questionnaire)
        @questionnaire = questionnaire
      end

      # Finds and group responses by user for each questionnaire's question.
      def query
        responses = Response.not_separator
                            .not_title_and_description
                            .joins(:question)
                            .where(questionnaire: @questionnaire)

        responses.sort_by { |response| response.question.position.to_i }.group_by { |a| a.user || a.session_token }.values
      end
    end
  end
end
