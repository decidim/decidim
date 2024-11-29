# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user unreports a resource content.
    class BulkUnreportContent < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user performing the action
      def initialize(reportable, current_user)
        @reportable = reportable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource content.
      # - :invalid if the resource content is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @reportable.reported?

        unreport!
        broadcast(:ok, @reportable)
      end

      private

      def unreport!
        @reportable.moderation.destroy!
      end
    end
  end
end
