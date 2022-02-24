# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Questionnaire from the admin
      # panel.
      class UpdateQuestionStatus < Decidim::Command
        class InvalidStatus < StandardError; end

        # Initializes a UpdateQuestionnaire Command.
        #
        # form - The form from which to get the data.
        # questionnaire - The current instance of the questionnaire to be updated.
        def initialize(question, current_user)
          @question = question
          @current_user = current_user
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          Decidim::Meetings::Question.transaction do
            update_question
          end

          broadcast(:ok)
        rescue InvalidStatus
          broadcast(:invalid)
        end

        private

        attr_reader :question, :current_user

        def update_question
          Decidim.traceability.update!(
            question,
            current_user,
            status: new_status(question)
          )
        end

        def new_status(question)
          if question.unpublished?
            Decidim::Meetings::Question.statuses[:published]
          elsif question.published?
            Decidim::Meetings::Question.statuses[:closed]
          else
            raise InvalidStatus
          end
        end
      end
    end
  end
end
