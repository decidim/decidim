# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user closes a collaborative_draft.
    class CloseCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # collaborative_draft     - The collaborative_draft to close.
      # current_user - The current user.
      def initialize(collaborative_draft, current_user)
        @collaborative_draft = collaborative_draft
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the collaborative_draft is published.
      # - :invalid if the collaborative_draft's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @collaborative_draft.closed?
        return broadcast(:invalid) if @collaborative_draft.published?
        return broadcast(:invalid) unless @collaborative_draft.authors.exists? @current_user.id

        transaction do
          @collaborative_draft.requesters.each do |requester_user|
            RejectAccessToCollaborativeDraft.call(@collaborative_draft, current_user, requester_user)
          end

          close_collaborative_draft
          send_notification_to_authors
        end

        broadcast(:ok, @collaborative_draft)
      end

      private

      def close_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          state: "closed"
        )
      end

      def send_notification_to_authors
        recipient_ids = @collaborative_draft.authors.pluck(:id) - [@current_user.id]
        return if recipient_ids.blank?

        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_closed",
          event_class: Decidim::Proposals::CollaborativeDraftClosedEvent,
          resource: @collaborative_draft,
          recipient_ids: recipient_ids.uniq,
          extra: {
            author_id: @current_user.id
          }
        )
      end
    end
  end
end
