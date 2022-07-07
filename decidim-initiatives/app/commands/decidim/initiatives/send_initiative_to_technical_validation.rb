# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that sends an
    # existing initiative to technical validation.
    class SendInitiativeToTechnicalValidation < Decidim::Command
      # Public: Initializes the command.
      #
      # initiative - Decidim::Initiative
      # current_user - the user performing the action
      def initialize(initiative, current_user)
        @initiative = initiative
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        @initiative = Decidim.traceability.perform_action!(
          :send_to_technical_validation,
          initiative,
          current_user
        ) do
          initiative.validating!
          initiative
        end

        notify_admins

        broadcast(:ok, initiative)
      end

      private

      attr_reader :initiative, :current_user

      def notify_admins
        affected_users = Decidim::User.org_admins_except_me(current_user).all

        data = {
          event: "decidim.events.initiatives.initiative_sent_to_technical_validation",
          event_class: Decidim::Initiatives::InitiativeSentToTechnicalValidationEvent,
          resource: initiative,
          affected_users: affected_users,
          force_send: true
        }

        Decidim::EventsManager.publish(**data)
      end
    end
  end
end
