# frozen_string_literal: true

module Decidim
  module Surveys
    # A class used to collect user answers for a survey
    class SurveyUserAnswers < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # survey - a Survey object
      def self.for(survey)
        new(survey).query
      end

      # Initializes the class.
      #
      # survey = a Survey object
      def initialize(survey)
        @survey = survey
      end

      # Finds and group answers by user for each survey's question.
      def query
        answers = SurveyAnswer.where(survey: @survey)
        answers.sort_by { |answer| answer.question.position }.group_by(&:user).values
      end
    end
  end
end
