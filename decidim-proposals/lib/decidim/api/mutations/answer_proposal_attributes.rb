# frozen_string_literal: true

module Decidim
  module Proposals
    class AnswerProposalAttributes < Decidim::Api::Types::BaseInputObject
      graphql_name "ProposalAttributes"
      description "Attributes of a proposal"

      argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this proposal", required: false
      argument :cost, GraphQL::Types::Float, description: "Estimated cost of the proposal", required: false
      argument :cost_report, GraphQL::Types::JSON, description: "Report on expenses", required: false
      argument :execution_period, GraphQL::Types::JSON, description: "Report on the execution perioid", required: false
      argument :state, GraphQL::Types::String,
               description: "The answer status in which the proposal is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: false
    end
  end
end
