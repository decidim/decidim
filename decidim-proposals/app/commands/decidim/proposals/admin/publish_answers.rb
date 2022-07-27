# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic to publish many answers at once.
      class PublishAnswers < Decidim::Command
        # Public: Initializes the command.
        #
        # component - The component that contains the answers.
        # user - the Decidim::User that is publishing the answers.
        # proposal_ids - the identifiers of the proposals with the answers to be published.
        def initialize(component, user, proposal_ids)
          @component = component
          @user = user
          @proposal_ids = proposal_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are not proposals to publish.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless proposals.any?

          proposals.each do |proposal|
            transaction do
              mark_proposal_as_answered(proposal)
              notify_proposal_answer(proposal)
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :proposal_ids

        def proposals
          @proposals ||= Decidim::Proposals::Proposal
                         .published
                         .answered
                         .state_not_published
                         .where(component:)
                         .where(id: proposal_ids)
        end

        def mark_proposal_as_answered(proposal)
          Decidim.traceability.perform_action!(
            "publish_answer",
            proposal,
            user
          ) do
            proposal.update!(state_published_at: Time.current)
          end
        end

        def notify_proposal_answer(proposal)
          NotifyProposalAnswer.call(proposal, nil)
        end
      end
    end
  end
end
