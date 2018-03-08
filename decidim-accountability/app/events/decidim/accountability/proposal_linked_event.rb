# frozen_string_literal: true

module Decidim
  module Accountability
    class ProposalLinkedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :proposal_title, :proposal_path

      def proposal_path
        @proposal_path ||= Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def proposal_title
        @proposal_title ||= proposal.title
      end

      def proposal
        @proposal ||= resource.linked_resources(:proposals, "included_proposals").where(id: extra[:proposal_id]).first
      end
    end
  end
end
