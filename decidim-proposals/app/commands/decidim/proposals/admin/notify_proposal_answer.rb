# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command to notify about the change of the published state for a proposal.
      class NotifyProposalAnswer < Decidim::Command
        # Public: Initializes the command.
        #
        # proposal - The proposal to write the answer for.
        # initial_state - The proposal state before the current process.
        def initialize(proposal, initial_state)
          @proposal = proposal
          @initial_state = initial_state.to_s
        end

        # Executes the command. Broadcasts these events:
        #
        # - :noop when the answer is not published or the state didn't changed.
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          if proposal.published_state? && state_changed?
            transaction do
              increment_score
              notify_followers
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :proposal, :initial_state

        def state_changed?
          initial_state != proposal.state.to_s
        end

        def notify_followers
          if proposal.accepted?
            publish_event(
              "decidim.events.proposals.proposal_accepted",
              Decidim::Proposals::AcceptedProposalEvent
            )
          elsif proposal.rejected?
            publish_event(
              "decidim.events.proposals.proposal_rejected",
              Decidim::Proposals::RejectedProposalEvent
            )
          elsif proposal.evaluating?
            publish_event(
              "decidim.events.proposals.proposal_evaluating",
              Decidim::Proposals::EvaluatingProposalEvent
            )
          end
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event:,
            event_class:,
            resource: proposal,
            affected_users: proposal.notifiable_identities,
            followers: proposal.followers - proposal.notifiable_identities
          )
        end

        def increment_score
          if proposal.accepted?
            proposal.coauthorships.find_each do |coauthorship|
              Decidim::Gamification.increment_score(coauthorship.user_group || coauthorship.author, :accepted_proposals)
            end
          elsif initial_state == "accepted"
            proposal.coauthorships.find_each do |coauthorship|
              Decidim::Gamification.decrement_score(coauthorship.user_group || coauthorship.author, :accepted_proposals)
            end
          end
        end
      end
    end
  end
end
