# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user publishes a draft proposal.
    class PublishProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to publish.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the proposal is published.
      # - :invalid if the proposal's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @proposal.authored_by?(@current_user)

        transaction do
          @proposal.update published_at: Time.current
          increment_scores
          send_notification
          send_notification_to_participatory_space
        end

        broadcast(:ok, @proposal)
      end

      private

      def send_notification
        return if @proposal.coauthorships.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @proposal,
          recipient_ids: coauthors_followers(@proposal)
        )
      end

      def send_notification_to_participatory_space
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @proposal,
          recipient_ids: @proposal.participatory_space.followers.pluck(:id) - coauthors_followers(@proposal),
          extra: {
            participatory_space: true
          }
        )
      end

      def coauthors_followers(_proposal)
        followers_ids = []
        @proposal.authors.each do |author|
          followers_ids += author.followers.pluck(:id)
        end
        followers_ids
      end

      def increment_scores
        @proposal.authors.each do |author|
          Decidim::Gamification.increment_score(author, :proposals)
        end
      end
    end
  end
end
