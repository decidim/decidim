# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user requests access
    # to edit a collaborative draft.
    class RequestAccessToCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # collaborative_draft     - A Decidim::Proposals::CollaborativeDraft object.
      # current_user - The current user and requester user
      def initialize(collaborative_draft, current_user)
        @collaborative_draft = collaborative_draft
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if it wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @current_user.nil?
        return broadcast(:invalid) if @collaborative_draft.state != "open"

        @collaborative_draft.collaborator_requests.create!(user: @current_user)
        notify_collaborative_draft_authors
        broadcast(:ok, @collaborative_draft)
      end

      private

      def notify_collaborative_draft_authors
        recipient_ids = @collaborative_draft.authors.pluck(:id)
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_access_requested",
          event_class: Decidim::Proposals::CollaborativeDraftAccessRequestedEvent,
          resource: @collaborative_draft,
          recipient_ids: recipient_ids.uniq,
          extra: {
            requester_id: @current_user.id
          }
        )
      end
    end
  end
end
