# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user requests access
    # to edit a collaborative draft.
    class RequestAccessToCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # collaborative_draft     - A Decidim::Proposals::CollaborativeDraft object.
      # current_user - The current user and requester user
      def initialize(form, current_user)
        @form = form
        @collaborative_draft = form.collaborative_draft
        @current_user = current_user
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
