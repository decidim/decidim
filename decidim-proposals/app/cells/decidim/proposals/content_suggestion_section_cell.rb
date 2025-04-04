# frozen_string_literal: true

module Decidim
  module Proposals
    class ContentSuggestionSectionCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::TooltipHelper
      include Decidim::CardHelper
      include Decidim::LayoutHelper
      include ApplicationHelper

      def show
        render if suggested_content_enabled?
      end

      def suggested_proposals
        case suggested_content_criteria
        when "most_recent"
          recent_proposals
        when "location"
          proposals = proposals_by_location
          proposals += random_proposals(suggested_content_limit - proposals.length) if proposals.length < suggested_content_limit
          proposals
        when "taxonomy"
          proposals = proposals_by_taxonomy
          proposals += random_proposals(suggested_content_limit - proposals.length) if proposals.length < suggested_content_limit
          proposals
        else
          random_proposals(suggested_content_limit)
        end
      end

      def base_query
        Decidim::Proposals::Proposal.published.except_rejected.not_hidden.not_withdrawn
                                    .where(component: current_participatory_space.components
                                    .where(manifest_name: "proposals").published)
                                    .where.not(id: model.id)
      end

      def random_proposals(limit)
        base_query.order("RANDOM()").limit(limit)
      end

      def recent_proposals
        base_query.order_by_most_recent.limit(suggested_content_limit)
      end

      def proposals_by_location
        return [] unless model.geocoded?

        base_query.near([model.latitude, model.longitude], Decidim::Proposals.suggestions_by_location_distance).limit(suggested_content_limit)
      end

      def proposals_by_taxonomy
        return [] unless model.taxonomies.any?

        taxonomy_ids = model.taxonomies.pluck(:id)
        base_query.includes(:taxonomizations).where.not({ taxonomizations: { id: nil } }).where({ taxonomizations: { taxonomy_id: taxonomy_ids } })
      end

      def suggested_content_enabled?
        model.component[:settings].dig("global", "content_suggestions_enabled") == true
      end

      def suggested_content_limit
        limit = model.component[:settings].dig("global", "content_suggestions_limit").to_i
        if limit.positive? && limit <= 10
          limit
        elsif limit > 10
          10
        else
          Decidim::Proposals.default_content_suggestions_limit
        end
      end

      def suggested_content_criteria
        model.component[:settings].dig("global", "content_suggestions_criteria")
      end
    end
  end
end
