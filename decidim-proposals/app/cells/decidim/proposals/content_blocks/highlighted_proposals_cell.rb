# frozen_string_literal: true

module Decidim
  module Proposals
    module ContentBlocks
      class HighlightedProposalsCell < Decidim::ContentBlocks::HighlightedElementsCell
        def base_relation
          @base_relation ||= Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn.where(component: published_components)
        end

        private

        def limit
          Decidim::Proposals.config.process_group_highlighted_proposals_limit
        end
      end
    end
  end
end
