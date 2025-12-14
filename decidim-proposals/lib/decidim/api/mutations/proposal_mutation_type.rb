# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "ProposalMutation"
      description "a proposal which includes its available mutations"

      field :answer, mutation: Decidim::Proposals::ProposalAnswerType, description: "Answers a proposal"
      field :unvote, mutation: Decidim::Proposals::UnvoteProposalType, description: "Removes a vote from a proposal"
      field :vote, mutation: Decidim::Proposals::VoteProposalType, description: "Votes a proposal"
    end
  end
end
