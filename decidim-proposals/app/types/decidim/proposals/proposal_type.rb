# frozen_string_literal: true

module Decidim
  module Proposals
    ProposalType = GraphQL::ObjectType.define do
      name "Proposal"
      description "A proposal"

      field :id, !types.ID
      field :title, !types.String, "This proposal's title"
      field :body, types.String, "This proposal's body"
      field :state, types.String, "The state in which proposal is in"
      field :address, types.String, "The physical address (location) of this proposal"

      field :publishedAt, Decidim::Core::DateTimeType do
        description "The date and time this proposal was published"
        property :published_at
      end

      field :endorsementsCount, types.Int do
        description "The total amount of endorsements the proposal has received"
        property :proposal_endorsements_count
      end

      field :voteCount, types.Int do
        description "The total amount of votes the proposal has received"
        resolve ->(proposal, _args, _ctx) {
          current_component = proposal.component
          proposal.proposal_votes_count unless current_component.current_settings.votes_hidden?
        }
      end
    end
  end
end
