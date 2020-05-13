# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This command is executed when the user destroys a Questionnaire from the admin
      # panel.
      class DestroyQuestionnaire < UpdateQuestionnaire
        # Initializes the command.
        #
        # qoestionnaire - the questionnaire to destroy
        def initialize(questionnaire)
          @questionnaire = questionnaire
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if answered?

          Decidim::Forms::Questionnaire.transaction do
            questionnaire.destroy!
          end

          broadcast(:ok)
        end

        private

        attr_reader :questionnaire

        def answered?
          questionnaire.answers.any? || questionnaire.question_answers.any?
        end
      end
    end
  end
end
