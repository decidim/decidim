# frozen_string_literal: true

module Decidim
  module Forms
    # A class used to collect user answers for a questionnaire
    class QuestionnaireParticipants < Decidim::Query
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

      # Finds all Answers for the questionnaire (unique session_tokens).
      # Because exporters only have access to the Answers this
      # is used as an indirect way to access the participants
      # (see #participants and #participant)
      def query
        Answer.where(questionnaire: @questionnaire)
      end

      def participant(session_token)
        query.find_by(session_token:)
      end

      def participants
        subquery = query.select("DISTINCT ON (decidim_forms_answers.session_token) decidim_forms_answers.*")
        Answer.select("*").from(subquery).order(:created_at)
      end

      def count_participants
        query.select(:session_token).distinct.count
      end
    end
  end
end
