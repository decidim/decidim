# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic when a user or organization unvotes an initiative.
    class UnvoteInitiative < Rectify::Command
      # Public: Initializes the command.
      #
      # initiative   - A Decidim::Initiative object.
      # current_user - The current user.
      # group_id     - Decidim user group id
      def initialize(initiative, current_user, group_id)
        @initiative = initiative
        @current_user = current_user
        @decidim_user_group_id = group_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the initiative.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_initiative_vote
        broadcast(:ok, @initiative)
      end

      private

      def destroy_initiative_vote
        Initiative.transaction do
          @initiative
            .votes
            .where(
              author: @current_user,
              decidim_user_group_id: @decidim_user_group_id
            )
            .destroy_all
        end
      end
    end
  end
end
