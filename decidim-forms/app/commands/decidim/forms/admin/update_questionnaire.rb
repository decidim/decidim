# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # This command is executed when the user changes a Questionnaire from the admin
      # panel.
      class UpdateQuestionnaire < Decidim::Command
        # Initializes a UpdateQuestionnaire Command.
        #
        # form - The form from which to get the data.
        # questionnaire - The current instance of the questionnaire to be updated.
        def initialize(form, questionnaire, user)
          @form = form
          @questionnaire = questionnaire
          @user = user
        end

        # Updates the questionnaire if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Decidim.traceability.perform_action!("update",
                                               @questionnaire,
                                               @user) do
            update_questionnaire
          end

          broadcast(:ok)
        end

        private

        def update_questionnaire
          @questionnaire.update!(title: @form.title,
                                 description: @form.description,
                                 tos: @form.tos)
        end
      end
    end
  end
end
