# frozen_string_literal: true

module Decidim
  module Proposals
    class NotifyProposalsMentionedJob < ApplicationJob
      def perform(comment, proposal_metadata)
        linked_proposals = proposal_metadata.linked_proposals
        linked_proposals.each do |proposal|
          recipient_ids = [proposal.decidim_author_id]
          Decidim::EventsManager.publish(
            event: "decidim.events.comments.proposal_mentioned",
            event_class: Decidim::Proposals::ProposalMentionedEvent,
            resource: comment.root_commentable,
            recipient_ids: recipient_ids,
            extra: {
              comment_id: comment.id,
              mentioned_proposal_id: proposal.id
            }
          )
        end
      end
    end
  end
end
