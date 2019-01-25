# frozen_string_literal: true

module Decidim
  module Proposals
    class NotifyProposalsMentionedJob < ApplicationJob
      def perform(comment_id, linked_proposals)
        comment = Decidim::Comments::Comment.find(comment_id)
        
        linked_proposals.each do |proposal_id|
          proposal = Proposal.find(proposal_id)
          next if proposal.decidim_author_id.blank?

          recipient_ids = [proposal.decidim_author_id]
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_mentioned",
            event_class: Decidim::Proposals::ProposalMentionedEvent,
            resource: comment.root_commentable,
            recipient_ids: recipient_ids,
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
