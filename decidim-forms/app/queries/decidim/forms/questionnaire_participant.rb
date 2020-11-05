# frozen_string_literal: true

module Decidim
  module Forms
    # A class used to collect user answers for a questionnaire
    class QuestionnaireParticipant < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # questionnaire - a Questionnaire object
      # session_token = the session_token used by the questionnaire participant
      def self.for(questionnaire, session_token)
        new(questionnaire, session_token).query
      end

      # Initializes the class.
      #
      # questionnaire = a Questionnaire object
      # session_token = the session_token used by the questionnaire participant
      def initialize(questionnaire, session_token)
        @questionnaire = questionnaire
        @token = session_token
      end

      # Returns query with participant info
      def query
        answers.select(:session_token, :decidim_user_id, :ip_hash).first
      end

      # Finds the participant's answers.
      def answers
        Answer.where(questionnaire: @questionnaire, session_token: @token)
      end
    end
  end
end
