# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user destroys a Question
      # from the admin panel.
      class DestroyQuestion < Rectify::Command
        def initialize(question, current_user)
          @question = question
          @current_user = current_user
        end

        # Destroys the question if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          destroy_question!

          broadcast(:ok, question)
        end

        private

        attr_reader :question, :current_user

        def invalid?
          question.election.started?
        end

        def destroy_question!
          Decidim.traceability.perform_action!(
            :delete,
            question,
            current_user,
            visibility: "all"
          ) do
            question.destroy!
          end
        end
      end
    end
  end
end
