# frozen_string_literal: true

module Decidim
  module Proposals
    class NotifyProposalsMentionedJob < ApplicationJob
      def perform(comment_id, linked_proposals)
        comment = Decidim::Comments::Comment.find(comment_id)

        linked_proposals.each do |proposal_id|
          proposal = Proposal.find(proposal_id)
          affected_users = proposal.notifiable_identities

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_mentioned",
            event_class: Decidim::Proposals::ProposalMentionedEvent,
            resource: comment.root_commentable,
            affected_users:,
            extra: {
              comment_id: comment.id,
              mentioned_proposal_id: proposal_id
            }
          )
        end
      end
    end
  end
end
