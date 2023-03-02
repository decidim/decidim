# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the highlighted proposals for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedProposalsForComponentCell < Decidim::ViewModel
      include Decidim::ComponentPathHelper
      include Decidim::CardHelper

      def show
        render unless items_blank?
      end

      def items_blank?
        proposals_count.zero?
      end

      private

      def proposals_count
        @proposals_count ||= base_relation.size
      end

      def proposals
        @proposals ||= case options[:order]
                       when "recent"
                         base_relation.order_by_most_recent
                       else
                         base_relation.order_randomly(random_seed)
                       end
      end

      def base_relation
        Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn.where(component: model)
      end

      def decidim_proposals
        return unless single_component?

        Decidim::EngineRouter.main_proxy(model)
      end

      def single_component?
        @single_component ||= model.is_a?(Decidim::Component)
      end

      def proposals_to_render
        @proposals_to_render ||= proposals.includes([:amendable, :category, :component, :scope]).limit(Decidim::Proposals.config.participatory_space_highlighted_proposals_limit)
      end

      def cache_hash
        hash = []
        hash << "decidim/proposals/highlighted_proposals_for_component"
        hash << proposals.cache_key_with_version
        hash << I18n.locale.to_s
        hash.join(Decidim.cache_key_separator)
      end

      def random_seed
        (rand * 2) - 1
      end
    end
  end
end
