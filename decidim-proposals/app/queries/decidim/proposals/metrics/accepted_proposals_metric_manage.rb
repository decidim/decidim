# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class AcceptedProposalsMetricManage < Decidim::Proposals::Metrics::ProposalsMetricManage
        def initialize(day_string, organization)
          super(day_string, organization)
          @metric_name = "accepted_proposals"
        end

        private

        def query
          @query = @query.where("decidim_proposals_proposals.published_at <= ?", end_time).accepted
          @query = @query.group("decidim_categorizations.id", :participatory_space_type, :participatory_space_id)
        end
      end
    end
  end
end
