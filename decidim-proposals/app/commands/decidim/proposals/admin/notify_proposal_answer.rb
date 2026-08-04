# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command to notify about the change of the published status for a proposal.
      class NotifyProposalAnswer < Decidim::Command
        # Public: Initializes the command.
        #
        # proposal - The proposal to write the answer for.
        # initial_status - The proposal status before the current process.
        def initialize(proposal, initial_status)
          @proposal = proposal
          @initial_status = initial_status
        end

        # Executes the command. Broadcasts these events:
        #
        # - :noop when the answer is not published or the status did not changed.
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if proposal.blank?

          if proposal.published_status? && status_changed?
            transaction do
              increment_score
              notify_followers
              notify_authors
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :proposal, :initial_status

        def status_changed?
          initial_status_token != proposal.status.to_s
        end

        def initial_status_token
          initial_status.respond_to?(:token) ? initial_status.token : initial_status
        end

        def notify_followers
          return if proposal.status == "not_answered"

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_status_changed",
            event_class: Decidim::Proposals::ProposalStatusChangedEvent,
            resource: proposal,
            followers: proposal.followers - proposal.notifiable_identities
          )
        end

        def notify_authors
          return if proposal.status == "not_answered"

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_status_changed_for_authors",
            event_class: Decidim::Proposals::ProposalStatusChangedEvent,
            resource: proposal,
            affected_users: proposal.authors,
            extra: { force_email: true }
          )
        end

        def increment_score
          if proposal.accepted?
            proposal.coauthorships.find_each do |coauthorship|
              Decidim::Gamification.increment_score(coauthorship.author, :accepted_proposals)
            end
          elsif initial_status == "accepted"
            proposal.coauthorships.find_each do |coauthorship|
              Decidim::Gamification.decrement_score(coauthorship.author, :accepted_proposals)
            end
          end
        end
      end
    end
  end
end
