# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to delete a comment
    class DeleteComment < Decidim::Command
      # Public: Initializes the command.
      #
      # comment - The comment to delete.
      # current_user - The user performing the action.
      def initialize(comment, current_user)
        @comment = comment
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if comment isn't authored by current_user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless comment.authored_by?(current_user)

        delete_comment

        broadcast(:ok)
      end

      private

      attr_reader :comment, :current_user

      def delete_comment
        Decidim.traceability.perform_action!(
          :delete,
          comment,
          current_user,
          visibility: "public-only"
        ) do
          comment.delete!
        end
      end
    end
  end
end
