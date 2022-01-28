# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user destroys an Answer
      # from the admin panel.
      class DestroyAnswer < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(answer, current_user)
          @answer = answer
          @current_user = current_user
          @attached_to = answer
        end

        # Destroys the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          destroy_answer

          broadcast(:ok, answer)
        end

        private

        attr_reader :answer, :current_user

        def invalid?
          answer.question.election.started?
        end

        def destroy_answer
          Decidim.traceability.perform_action!(
            :delete,
            answer,
            current_user,
            visibility: "all"
          ) do
            answer.destroy!
          end
        end
      end
    end
  end
end
