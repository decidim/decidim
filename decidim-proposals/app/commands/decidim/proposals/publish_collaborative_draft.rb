# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user publishes a draft collaborative_draft.
    class PublishCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # collaborative_draft     - The collaborative_draft to publish.
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
        return broadcast(:invalid) if @collaborative_draft.author != @current_user

        transaction do
          @collaborative_draft.update published_at: Time.current
          send_notification
          send_notification_to_participatory_space
        end

        broadcast(:ok, @collaborative_draft)
      end

      private

      def send_notification
        # TODO:
        return
        return if @collaborative_draft.author.blank?

        Decidim::EventsManager.publish(
          event: "decidim.events.collaborative_drafts.collaborative_draft_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @collaborative_draft,
          recipient_ids: @collaborative_draft.author.followers.pluck(:id)
        )
      end

      def send_notification_to_participatory_space
        # TODO:
        return
        Decidim::EventsManager.publish(
          event: "decidim.events.collaborative_drafts.collaborative_draft_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @collaborative_draft,
          recipient_ids: @collaborative_draft.participatory_space.followers.pluck(:id) - @collaborative_draft.author.followers.pluck(:id),
          extra: {
            participatory_space: true
          }
        )
      end
    end
  end
end
