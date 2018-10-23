# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class AcceptedProposalsMetricManage < Decidim::Proposals::Metrics::ProposalsMetricManage
        def metric_name
          "accepted_proposals"
        end

        private

        def query
          return @query if @query

          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(@organization).public_spaces
          end
          components = Decidim::Component.where(participatory_space: spaces).published
          @query = Decidim::Proposals::Proposal.where(component: components).joins(:component)
                                               .left_outer_joins(:category)
          @query = @query.where("decidim_proposals_proposals.published_at <= ?", end_time).accepted
          @query = @query.group("decidim_categorizations.id", :participatory_space_type, :participatory_space_id)
          @query
        end
      end
    end
  end
end
