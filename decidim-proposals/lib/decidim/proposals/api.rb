# frozen_string_literal: true

module Decidim
  module Proposals
    autoload :ProposalsMetricInterface, "decidim/api/proposals_metric_interface"
    autoload :AcceptedProposalsMetricInterface, "decidim/api/accepted_proposals_metric_interface"
    autoload :VotesMetricInterface, "decidim/api/votes_metric_interface"
  end
end
