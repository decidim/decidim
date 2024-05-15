# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposals
    module ProposalsHelper
      def proposal_reason_callout_announcement
        {
          title: translated_attribute(@proposal.proposal_state&.announcement_title),
          body: decidim_sanitize_editor_admin(translated_attribute(@proposal.answer))
        }
      end

      def proposal_has_costs?
        @proposal.cost.present? &&
          translated_attribute(@proposal.cost_report).present? &&
          translated_attribute(@proposal.execution_period).present?
      end

      def resource_version(resource, options = {})
        return unless resource.respond_to?(:amendable?) && resource.amendable?

        super
      end
    end
  end
end
