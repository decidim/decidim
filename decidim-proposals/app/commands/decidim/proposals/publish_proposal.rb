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
          publish_proposal
          increment_scores
          send_notification
          send_notification_to_participatory_space
        end

        broadcast(:ok, @proposal)
      end

      private

      # Prevent PaperTrail from creating an additional version
      # in the proposal multi-step creation process (step 4: publish)
      def publish_proposal
        PaperTrail.request(enabled: false) do
          @proposal.update published_at: Time.current
        end
      end

      def send_notification
        return if @proposal.coauthorships.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @proposal,
          followers: coauthors_followers
        )
      end

      def send_notification_to_participatory_space
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.proposal_published",
          event_class: Decidim::Proposals::PublishProposalEvent,
          resource: @proposal,
          followers: @proposal.participatory_space.followers - coauthors_followers,
          extra: {
            participatory_space: true
          }
        )
      end

      def coauthors_followers
        @coauthors_followers ||= @proposal.authors.flat_map(&:followers)
      end

      def increment_scores
        @proposal.coauthorships.find_each do |coauthorship|
          if coauthorship.user_group
            Decidim::Gamification.increment_score(coauthorship.user_group, :proposals)
          else
            Decidim::Gamification.increment_score(coauthorship.author, :proposals)
          end
        end
      end
    end
  end
end
