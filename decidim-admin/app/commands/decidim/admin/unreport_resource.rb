# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user unreports a resource.
    class UnreportResource < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      def initialize(reportable)
        @reportable = reportable
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
        @reportable.moderation.update_attributes!(report_count: 0, hidden_at: nil)
      end
    end
  end
end
