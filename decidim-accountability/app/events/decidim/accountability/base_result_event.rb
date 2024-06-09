# frozen_string_literal: true

module Decidim
  module Accountability
    class BaseResultEvent < Decidim::Events::SimpleEvent
      i18n_attributes :proposal_title, :proposal_path

      def resource_text
        translated_attribute(resource.description)
      end

      def proposal_title
        @proposal_title ||= decidim_sanitize_translated(proposal.title)
      end

      def proposal_path
        @proposal_path ||= Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def proposal
        @proposal ||= resource.linked_resources(:proposals, "included_proposals").find_by(id: extra[:proposal_id])
      end

      def hidden_resource?
        super || (proposal.respond_to?(:hidden?) && proposal.hidden?)
      end
    end
  end
end
