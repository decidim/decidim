# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the highlighted proposals for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedProposalsForComponentCell < Decidim::ViewModel
      include Decidim::ComponentPathHelper

      def show
        render unless proposals_count.zero?
      end

      private

      def proposals
        @proposals ||= Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn
                                                   .where(component: model)
                                                   .order_randomly((rand * 2) - 1)
      end

      def proposals_to_render
        @proposals_to_render ||= proposals.includes([:amendable, :category, :component, :scope]).limit(Decidim::Proposals.config.participatory_space_highlighted_proposals_limit)
      end

      def proposals_count
        @proposals_count ||= proposals.count
      end

      def cache_hash
        hash = []
        hash << "decidim/proposals/highlighted_proposals_for_component"
        hash << proposals.cache_key_with_version
        hash << I18n.locale.to_s
        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
