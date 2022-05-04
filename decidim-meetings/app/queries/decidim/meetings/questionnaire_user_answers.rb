# frozen_string_literal: true

module Decidim
  module Meetings
    # A class used to collect user answers for a questionnaire
    class QuestionnaireUserAnswers < Decidim::Query
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

      # Finds and group answers by user for each questionnaire's question.
      def query
        answers = Answer.joins(:question).where(questionnaire: @questionnaire)

        answers.sort_by { |answer| answer.question.position }.group_by(&:user).values
      end
    end
  end
end
