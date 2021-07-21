# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalMentionedEvent < Decidim::Events::SimpleEvent
      include Decidim::ApplicationHelper

      i18n_attributes :mentioned_proposal_title

      def safe_resource_translated_text
        resource_text
      end

      def perform_translation?
        false
      end

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
