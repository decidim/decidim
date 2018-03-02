# frozen-string_literal: true

module Decidim
  module Comments
    class ProposalMentionedEvent < Decidim::Events::SimpleEvent
      def email_subject
        I18n.t(
          "decidim.events.comments.proposal_mentioned.email_subject",
          mentioned_proposal_title: mentioned_proposal.title
        )
      end

      def email_intro
        I18n.t(
          "decidim.events.comments.proposal_mentioned.email_intro",
          mentioned_proposal_title: mentioned_proposal.title,
          resource_path: resource_path
        )
      end

      def notification_title
        I18n.t(
          "decidim.events.comments.proposal_mentioned.notification_title",
          mentioned_proposal_title: mentioned_proposal.title,
          resource_path: resource_path
        ).html_safe
      end

      private

      def mentioned_proposal
        @mentioned_proposal ||= Decidim::Proposals::Proposal.find(extra[:mentioned_proposal_id])
      end
    end
  end
end
