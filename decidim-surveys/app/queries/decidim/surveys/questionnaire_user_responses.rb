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
        return [] unless @questionnaire.questionnaire_for&.published_at.present?

        responses = Decidim::Forms::Response.joins(:question)
                                            .where(questionnaire: @questionnaire)
                                            .includes(:question, :user)
                                            .order("decidim_forms_questions.position")

        UserResponseCollection.new(responses.group_by(&:user).values)
      end
    end

    class UserResponseCollection
      include Enumerable

      def initialize(grouped_responses)
        @grouped_responses = grouped_responses
      end

      def each(&)
        @grouped_responses.each(&)
      end

      def find_in_batches(batch_size: 1000)
        @grouped_responses.each_slice(batch_size) do |batch|
          yield batch
        end
      end

      def find_each(&)
        @grouped_responses.each(&)
      end
    end
  end
end
