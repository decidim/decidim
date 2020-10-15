# frozen_string_literal: true

module Decidim
  module Admin
    class UnreportUser < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::User - The user reported
      # current_user - the user performing the action
      def initialize(reportable, current_user)
        @reportable = reportable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @reportable.reported?

        unreport!
        broadcast(:ok, @reportable)
      end

      private

      def unreport!
        Decidim.traceability.perform_action!(
          "unreport",
          @reportable.user_moderation,
          @current_user,
          extra: {
            reportable_type: @reportable.class.name,
            username: @reportable.name,
            user_id: @reportable.id
          }
        ) do
          @reportable.user_moderation.destroy!
        end
      end
    end
  end
end
