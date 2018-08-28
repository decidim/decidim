# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic to reject a user request to
    # contribute to a collaborative draft.
    class RejectAccessToCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # collaborative_draft     - A Decidim::Proposals::CollaborativeDraft object.
      # current_user - The current user.
      # requester_user - The user that requested to collaborate.
      def initialize(form, current_user)
        @form = form
        @collaborative_draft = form.collaborative_draft
        @current_user = current_user
        @requester_user = form.requester_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if it wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) if @current_user.nil?

        @collaborative_draft.requesters.delete @requester_user

        notify_collaborative_draft_requester
        notify_collaborative_draft_authors
        broadcast(:ok, @requester_user)
      end

      private

      def notify_collaborative_draft_authors
        recipient_ids = @collaborative_draft.authors.pluck(:id)
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_access_rejected",
          event_class: Decidim::Proposals::CollaborativeDraftAccessRejectedEvent,
          resource: @collaborative_draft,
          recipient_ids: recipient_ids.uniq,
          extra: {
            requester_id: @requester_user.id
          }
        )
      end

      def notify_collaborative_draft_requester
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_access_requester_rejected",
          event_class: Decidim::Proposals::CollaborativeDraftAccessRequesterRejectedEvent,
          resource: @collaborative_draft,
          recipient_ids: [@requester_user.id]
        )
      end
    end
  end
end
