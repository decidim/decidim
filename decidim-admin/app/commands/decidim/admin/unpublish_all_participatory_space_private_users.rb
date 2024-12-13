# frozen_string_literal: true

module Decidim
  module Admin
    class UnpublishAllParticipatorySpacePrivateUsers < Decidim::Command
      # Public: Initializes the command.
      #
      # participatory_space - the participatory space
      # current_user - the current user
      def initialize(participatory_space, current_user)
        @participatory_space = participatory_space
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        unpublish_all
        create_action_log
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :participatory_space, :current_user

      def unpublish_all
        # rubocop:disable Rails/SkipsModelValidations
        # Using update_all for performance reasons
        participatory_space.participatory_space_private_users.update_all(published: false)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def create_action_log
        Decidim.traceability.perform_action!(
          "unpublish_all_members",
          participatory_space,
          current_user,
          private_users_ids: participatory_space.participatory_space_private_users.pluck(:id)
        )
      end
    end
  end
end
