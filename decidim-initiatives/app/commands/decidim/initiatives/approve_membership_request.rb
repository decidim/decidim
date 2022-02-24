# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that creates a new initiative.
    class ApproveMembershipRequest < Decidim::Command
      # Public: Initializes the command.
      #
      # membership_request - A pending committee member
      def initialize(membership_request)
        @membership_request = membership_request
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        @membership_request.accepted!
        notify_applicant

        broadcast(:ok, @membership_request)
      end

      private

      def notify_applicant
        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.approve_membership_request",
          event_class: Decidim::Initiatives::ApproveMembershipRequestEvent,
          resource: @membership_request.initiative,
          affected_users: [@membership_request.user],
          force_send: true,
          extra: { author: @membership_request.initiative.author }
        )
      end
    end
  end
end
