# frozen_string_literal: true

module Decidim
  module Proposals
    autoload :ProposalMetricInterface, "decidim/api/proposal_metric_interface"
    autoload :AcceptedProposalMetricInterface, "decidim/api/accepted_proposal_metric_interface"
    autoload :VotesMetricInterface, "decidim/api/votes_metric_interface"
    autoload :ProposalMetricObjectInterface, "decidim/api/proposal_metric_object_interface"
    autoload :VotesMetricObjectInterface, "decidim/api/votes_metric_object_interface"
  end
end
