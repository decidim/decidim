# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalInputSort < Decidim::Core::BaseInputSort
      include Decidim::Core::HasPublishableInputSort
      include Decidim::Core::HasLikeableInputSort

      graphql_name "ProposalSort"
      description "A type used for sorting proposals"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
      argument :vote_count,
               type: GraphQL::Types::String,
               description: "Sort by number of votes, valid values are ASC or DESC. Will be ignored if votes are hidden",
               required: false,
               as: :proposal_votes_count
    end
  end
end
