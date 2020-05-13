# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This command is executed when the user creates a Questionnaire from the admin
      # panel.
      class CreateQuestionnaire < UpdateQuestionnaire
        # Initializes the command.
        #
        # form - The form from which to get the data.
        def initialize(form)
          @form = form
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          Decidim::Forms::Questionnaire.transaction do
            create_questionnaire
            update_questionnaire_questions if questionnaire.questions_editable?
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :questionnaire

        def create_questionnaire
          @questionnaire = Decidim::Forms::Questionnaire.create!(
            questionnaire_for: form.questionnaire_for,
            title: form.title,
            weight: form.weight,
            description: form.description,
            tos: form.tos
          )
        end
      end
    end
  end
end
