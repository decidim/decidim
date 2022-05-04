# frozen_string_literal: true

module Decidim
  module Accountability
    class ProposalLinkedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :proposal_title, :proposal_path

      def proposal_path
        @proposal_path ||= Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def proposal_title
        @proposal_title ||= translated_attribute(proposal.title)
      end

      def proposal
        @proposal ||= resource.linked_resources(:proposals, "included_proposals").find_by(id: extra[:proposal_id])
      end

      def resource_text
        translated_attribute(resource.description)
      end
    end
  end
end
