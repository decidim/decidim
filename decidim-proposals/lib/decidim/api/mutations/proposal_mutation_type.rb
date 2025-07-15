# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalMutationType < Decidim::Api::Types::BaseObject
      include Decidim::ApiResponseHelper

      graphql_name "ProposalMutation"
      description "a proposal which includes its available mutations"

      field :answer, mutation: Decidim::Proposals::AnswerProposalType, description: "Answers a proposal"
    end
  end
end
