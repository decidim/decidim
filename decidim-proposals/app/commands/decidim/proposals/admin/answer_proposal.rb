# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin answers a proposal.
      class AnswerProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # proposal - The proposal to write the answer for.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          answer_proposal
          notify_followers
          increment_score

          broadcast(:ok)
        end

        private

        attr_reader :form, :proposal

        def answer_proposal
          Decidim.traceability.perform_action!(
            "answer",
            proposal,
            form.current_user
          ) do
            proposal.update!(
              state: @form.state,
              answer: @form.answer,
              answered_at: Time.current
            )
          end
        end

        def notify_followers
          return if (proposal.previous_changes.keys & %w(state)).empty?

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
            event: event,
            event_class: event_class,
            resource: proposal,
            affected_users: proposal.notifiable_identities,
            followers: proposal.followers - proposal.notifiable_identities
          )
        end

        def increment_score
          return unless proposal.accepted?

          proposal.coauthorships.find_each do |coauthorship|
            if coauthorship.user_group
              Decidim::Gamification.increment_score(coauthorship.user_group, :accepted_proposals)
            else
              Decidim::Gamification.increment_score(coauthorship.author, :accepted_proposals)
            end
          end
        end
      end
    end
  end
end
