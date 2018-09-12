# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalMentionedEvent < Decidim::Events::SimpleEvent
      helper Decidim::ApplicationHelper

      i18n_attributes :mentioned_proposal_title

      private

      def mentioned_proposal_title
        present(mentioned_proposal).title
      end

      def mentioned_proposal
        @mentioned_proposal ||= Decidim::Proposals::Proposal.find(extra[:mentioned_proposal_id])
      end
    end
  end
end
